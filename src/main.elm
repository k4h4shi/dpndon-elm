module Main exposing (Model, Msg(..), init, main, update, view)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Attribute, Html, a, article, button, div, footer, h1, h2, input, nav, span, text)
import Html.Attributes as Attr exposing (class, disabled, href, value)
import Html.Events exposing (onClick, onInput)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)



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


type alias Dependency =
    { name : String
    , version : String
    , description : String
    , homepage : String
    }


type alias Model =
    { key : Nav.Key
    , url : Url.Url

    -- Top
    , packageName : String
    , dependencies : List Dependency
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { url = url
      , key = key
      , packageName = ""
      , dependencies =
            [ Dependency "babel-cli" "6.26.0" "Babel command line." "https://babeljs.io/"
            , Dependency "babel-preset-es2015" "6.24.1" "Babel preset for all es2015 plugins." "https://babeljs.io/"
            , Dependency "chai" "4.2.0" "BDD/TDD assertion library for node.js and the browser. Test framework agnostic." "https://www.chaijs.com/"
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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- ROUTING


type Route
    = TopRoute
    | NpmPackageRoute String


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map TopRoute Parser.top
        , Parser.map NpmPackageRoute (s "packages" </> string)
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

        Just (NpmPackageRoute packageName) ->
            viewNpmPackagePage model packageName



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
        [ div [ class "hero is-fullheight " ]
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


viewNpmPackagePage : Model -> String -> Document Msg
viewNpmPackagePage model packageName =
    let
        { dependencies } =
            model
    in
    { title = "Dpndon - " ++ packageName
    , body =
        [ div [ class "hero is-fullheight " ]
            [ viewHeader
            , div [ class "hero-body" ]
                [ div [ class "container has-text-centered" ]
                    [ h1 [ class "title" ] [ text packageName ]

                    -- TODO: 依存性のリストを表示する
                    ]
                ]
            , viewFooter
            ]
        ]
    }


viewNotFoundPage : Model -> Document Msg
viewNotFoundPage model =
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
                    [ a [ class "navbar-item", href "" ] [ text "dpndon" ]
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
