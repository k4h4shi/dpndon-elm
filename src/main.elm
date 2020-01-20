module Main exposing (Model, Msg(..), init, main, update, view)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Attribute, Html, a, article, br, button, div, footer, h1, h2, input, li, nav, p, small, span, strong, text, ul)
import Html.Attributes exposing (class, disabled, href, style, value)
import Html.Events exposing (onClick, onInput)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, fragment, oneOf, s, string)



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type DependencyType
    = ProdDependency
    | DevDependency
    | OptDependency
    | BundleDependency


type alias Dependency =
    { dependencyType : DependencyType
    , name : String
    , version : String
    , description : String
    , homepage : String
    }


type Tab
    = All
    | Prod
    | Dev
    | Opt
    | Bundle


type alias Model =
    { key : Nav.Key
    , url : Url.Url

    -- Top
    , packageName : String

    -- Packages
    , dependencies : List Dependency
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { url = url
      , key = key
      , packageName = ""
      , dependencies =
            -- TODO: 依存性の取得を実装する
            [ Dependency ProdDependency "babel-cli" "6.26.0" "Babel command line." "https://babeljs.io/"
            , Dependency DevDependency "babel-preset-es2015" "6.24.1" "Babel preset for all es2015 plugins." "https://babeljs.io/"
            , Dependency OptDependency "chai" "4.2.0" "BDD/TDD assertion library for node.js and the browser. Test framework agnostic." "https://www.chaijs.com/"
            , Dependency BundleDependency "chai" "4.2.0" "BDD/TDD assertion library for node.js and the browser. Test framework agnostic." "https://www.chaijs.com/"
            ]
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
      -- Top
    | Input String
    | Submit



-- Packages


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model
                | url = url
              }
            , Cmd.none
            )

        -- Top
        Input value ->
            ( { model | packageName = value }, Cmd.none )

        Submit ->
            let
                { url } =
                    model

                path =
                    "/packages/" ++ model.packageName

                nextUrl =
                    Url.toString { url | path = path }
            in
            ( { model | packageName = "" }, Nav.pushUrl model.key nextUrl )



-- Packages
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- ROUTING


type Route
    = TopRoute
    | NpmPackageRoute String Tab


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map TopRoute Parser.top
        , Parser.map NpmPackageRoute (s "packages" </> string </> fragment mapFragmentToTab)
        ]



-- VIEW


view : Model -> Document Msg
view model =
    let
        route =
            Parser.parse parser model.url
    in
    case
        route
    of
        Nothing ->
            viewNotFoundPage model

        Just TopRoute ->
            viewTopPage model

        Just (NpmPackageRoute packageName tabType) ->
            viewNpmPackagePage model packageName tabType



--- VIEW PAGES


viewTopPage : Model -> Document Msg
viewTopPage model =
    let
        { packageName } =
            model

        submitButtonDisabled =
            packageName == ""
    in
    { title = "Dpndon"
    , body =
        [ div [ class "hero is-fullheight" ]
            [ viewHeader
            , div [ class "hero-body" ]
                [ div [ class "container has-text-centered" ]
                    [ h1 [ class "title" ] [ text "Dpndon" ]
                    , h2 [ class "subtitle" ] [ text "List Homepages of npm modules that the project depend on." ]
                    , div [ class "field has-addons has-addons-centered " ]
                        [ div [ class "control" ]
                            [ input [ class "input", value packageName, onInput Input ] []
                            ]
                        , div [ class "control" ] [ button [ class "button is-primary", onClick Submit, disabled submitButtonDisabled ] [ text "Go" ] ]
                        ]
                    ]
                ]
            , viewFooter
            ]
        ]
    }


getTabActiveClass : Tab -> Tab -> String
getTabActiveClass tab target =
    if tab == target then
        "is-active"

    else
        ""


mapFragmentToTab : Maybe String -> Tab
mapFragmentToTab maybeStr =
    case maybeStr of
        Just str ->
            if str == "prod" then
                Prod

            else if str == "dev" then
                Dev

            else if str == "opt" then
                Opt

            else if str == "bundle" then
                Bundle

            else
                All

        Nothing ->
            All


filterDependencies : Tab -> List Dependency -> List Dependency
filterDependencies tab dependencies =
    case tab of
        All ->
            dependencies

        Prod ->
            List.filter (\dep -> dep.dependencyType == ProdDependency) dependencies

        Dev ->
            List.filter (\dep -> dep.dependencyType == DevDependency) dependencies

        Opt ->
            List.filter (\dep -> dep.dependencyType == OptDependency) dependencies

        Bundle ->
            List.filter (\dep -> dep.dependencyType == BundleDependency) dependencies


viewNpmPackagePage : Model -> String -> Tab -> Document Msg
viewNpmPackagePage model packageName tab =
    let
        { dependencies } =
            model
    in
    { title = "Dpndon - " ++ packageName
    , body =
        [ div [ style "min-height" "100vh", style "display" "flex", style "flex-direction" "column" ]
            [ viewHeader
            , div [ style "flex" "1" ]
                [ div [ class "container" ]
                    [ h1 [ class "title" ]
                        [ text packageName ]
                    , div [ class "tabs" ]
                        [ ul []
                            [ li [ class (getTabActiveClass tab All) ] [ a [ href "" ] [ text "All" ] ]
                            , li [ class (getTabActiveClass tab Prod) ] [ a [ href "#prod" ] [ text "Prod" ] ]
                            , li [ class (getTabActiveClass tab Dev) ] [ a [ href "#dev" ] [ text "Dev" ] ]
                            , li [ class (getTabActiveClass tab Opt) ] [ a [ href "#opt" ] [ text "Opt" ] ]
                            , li [ class (getTabActiveClass tab Bundle) ] [ a [ href "#bundle" ] [ text "Bundle" ] ]
                            ]
                        ]
                    , div []
                        (List.map
                            (\dependency ->
                                div [ class "box" ]
                                    [ article [ class "media" ]
                                        [ div [ class "media-content" ]
                                            [ div [ class "content" ]
                                                [ p
                                                    []
                                                    [ strong [] [ text dependency.name ], text " ", small [] [ text dependency.version ], br [] [], text dependency.description ]
                                                ]
                                            , nav [ class "level" ]
                                                [ div [ class "level-left" ]
                                                    [ span [ class "tag is-light" ]
                                                        [ text
                                                            (case dependency.dependencyType of
                                                                ProdDependency ->
                                                                    "prod"

                                                                DevDependency ->
                                                                    "dev"

                                                                OptDependency ->
                                                                    "opt"

                                                                BundleDependency ->
                                                                    "bundle"
                                                            )
                                                        ]
                                                    ]
                                                , div
                                                    [ class "level-right" ]
                                                    [ div [ class "level-item" ]
                                                        [ a [ class "button is-link is-light", href dependency.homepage ] [ text "Go to homepage" ]
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                            )
                            (filterDependencies tab dependencies)
                        )
                    ]
                ]
            , viewFooter
            ]
        ]
    }


viewNotFoundPage : Model -> Document Msg
viewNotFoundPage _ =
    { title = "Dpndon - Notfound"
    , body =
        [ div [ class "hero is-fullheight " ]
            [ viewHeader
            , div [ class "hero-body" ]
                [ div [ class "container has-text-centered" ]
                    [ h1 [ class "title" ] [ text "404" ]
                    , h2 [ class "subtitle" ] [ text "Sorry, the page not found" ]
                    ]
                ]
            , viewFooter
            ]
        ]
    }



--- VIEW COMMONS


viewHeader : Html Msg
viewHeader =
    div [ class "hero-head" ]
        [ nav [ class "navbar" ]
            [ div [ class "container" ]
                [ div [ class "navbar-brand" ]
                    [ a [ class "navbar-item", href "/" ] [ text "dpndon" ]
                    ]
                ]
            ]
        ]


viewFooter : Html Msg
viewFooter =
    footer [ class "hero-foot" ]
        [ div [ class "container has-text-centered" ]
            [ span [] [ text "© 2019" ]
            , text " "
            , a [ class "has-text-grey-dark", href "https:k4h4shi.com" ] [ text "k4h4shi" ]
            ]
        ]
