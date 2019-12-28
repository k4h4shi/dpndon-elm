module Main exposing (Model, Msg(..), init, main, update, view)

import Browser exposing (Document)
import Html exposing (Html, a, button, div, footer, h1, h2, input, nav, span, text)
import Html.Attributes exposing (class, href, value)
import Html.Events exposing (onClick, onInput)



-- MAIN


main : Program () Model Msg
main =
    Browser.document { init = init, update = update, view = view, subscriptions = subscriptions }



-- MODEL


type alias Model =
    { input : String
    }


initialModel : Model
initialModel =
    { input = "" }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )



-- UPDATE


type Msg
    = Input String
    | Reset


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input value ->
            ( { model | input = value }, Cmd.none )

        Reset ->
            ( { model | input = "" }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Dpndon"
    , body =
        [ div [ class "hero is-fullheight " ]
            [ viewHeader
            , viewMain model
            , viewFooter
            ]
        ]
    }


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


viewMain : Model -> Html Msg
viewMain model =
    div [ class "hero-body" ]
        [ div [ class "container has-text-centered" ]
            [ h1 [ class "title" ] [ text "Dpndon" ]
            , h2 [ class "subtitle" ] [ text "List Homepages of npm modules that the project depend on." ]
            , viewMainForm model
            ]
        ]


viewMainForm : Model -> Html Msg
viewMainForm model =
    div [ class "field has-addons has-addons-centered " ]
        [ div [ class "control" ]
            [ input [ class "input", value model.input, onInput Input ] []
            ]
        , div [ class "control" ] [ button [ class "button is-primary", onClick Reset ] [ text "Go" ] ]
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
