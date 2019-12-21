module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (Html, button, div, h1, h2, input, p, span, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { input : String
    }


init : Model
init =
    { input = "" }



-- UPDATE


type Msg
    = Input String
    | Reset


update : Msg -> Model -> Model
update msg model =
    case msg of
        Input value ->
            { model | input = value }

        Reset ->
            { model | input = "" }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewHeader
        , viewMain model
        , viewFooter
        ]


viewHeader : Html Msg
viewHeader =
    div []
        [ h1 [] [ text "dpndon" ]
        ]


viewMain : Model -> Html Msg
viewMain model =
    div []
        [ div []
            [ h2 [] [ text "Dpndon" ]
            , p [] [ text "List Homepages of npm modules that the project depend on." ]
            ]
        , div []
            [ input [ value model.input ] []
            , button [ onClick Reset ] [ text "Go" ]
            ]
        ]


viewFooter : Html Msg
viewFooter =
    div []
        [ span [] [ text "© 2019 k4h4shi" ]
        ]
