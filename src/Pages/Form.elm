module Pages.Form
    exposing
        ( Configuration
        , Model
        , Msg(..)
        , confDecoder
        , confEncoder
        , defaultConfiguration
        , initModel
        , update
        , viewElement
        )

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Framework.Button
import Framework.Color as Color exposing (Color(..), color)
import Framework.Logo as Logo
import Framework.Modifiers as Modifiers
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Http
import Json.Decode
import Json.Decode.Pipeline
import Json.Encode
import StyleElementsHack as Hack
import Svg
import Svg.Attributes as SA
import Task
import Validate
import Window


type alias Model =
    { errors : List Error
    , response : Maybe String

    -- focus - which FormField has focus at any given moment
    , focus : Maybe FormField

    -- showErrors - used to hide errors until the form is
    -- submitted for the first time
    , showErrors : Bool

    -- showPassword - toggle boolean to hide or show the password
    -- on user request
    , showPassword : Bool
    , formState : FormState

    -- FIELDS VALUES
    , fieldEmail : String
    , fieldPassword : String

    -- CONFIGURATION
    , conf : Configuration

    -- VIEWPORT SIZE
    , device : Window.Size
    }


type alias Configuration =
    { negative : Bool
    , logo : Logo.Logo
    , color : Color
    , background : String
    , title : String
    , submitText : String
    }


confEncoder : Configuration -> Json.Encode.Value
confEncoder conf =
    Json.Encode.object
        [ ( "negative", Json.Encode.string <| toString conf.negative )
        , ( "logo", Json.Encode.string <| toString conf.logo )
        , ( "color", Json.Encode.string <| toString conf.color )
        , ( "background", Json.Encode.string <| conf.background )
        , ( "title", Json.Encode.string <| conf.title )
        , ( "submitText", Json.Encode.string <| conf.submitText )
        ]


confDecoder : Json.Decode.Decoder Configuration
confDecoder =
    Json.Decode.Pipeline.decode Configuration
        |> Json.Decode.Pipeline.required "negative" (Json.Decode.string |> Json.Decode.andThen negativeDecoder)
        |> Json.Decode.Pipeline.required "logo" (Json.Decode.string |> Json.Decode.andThen logoDecoder)
        |> Json.Decode.Pipeline.required "color" (Json.Decode.string |> Json.Decode.andThen colorDecoder)
        |> Json.Decode.Pipeline.required "background" Json.Decode.string
        |> Json.Decode.Pipeline.required "title" Json.Decode.string
        |> Json.Decode.Pipeline.required "submitText" Json.Decode.string


negativeDecoder : String -> Json.Decode.Decoder Bool
negativeDecoder colorString =
    case colorString of
        "True" ->
            Json.Decode.succeed True

        "False" ->
            Json.Decode.succeed False

        _ ->
            Json.Decode.fail <| "I don't know a negative states named " ++ colorString


colorDecoder : String -> Json.Decode.Decoder Color
colorDecoder colorString =
    case colorString of
        "Primary" ->
            Json.Decode.succeed Primary

        "Danger" ->
            Json.Decode.succeed Danger

        "Warning" ->
            Json.Decode.succeed Warning

        "Link" ->
            Json.Decode.succeed Color.Link

        _ ->
            Json.Decode.fail <| "I don't know a color named " ++ colorString


logoDecoder : String -> Json.Decode.Decoder Logo.Logo
logoDecoder logoString =
    case logoString of
        "ElmMulticolor" ->
            Json.Decode.succeed Logo.ElmMulticolor

        "Strawberry" ->
            Json.Decode.succeed Logo.Strawberry

        "Watermelon" ->
            Json.Decode.succeed Logo.Watermelon

        _ ->
            Json.Decode.fail <| "I don't know a logo named " ++ logoString


initModel : String -> Model
initModel configuration =
    let
        result =
            Json.Decode.decodeString confDecoder
                configuration

        conf =
            case result of
                Ok value ->
                    value

                Err err ->
                    defaultConfiguration
    in
    { errors = []
    , response = Nothing
    , focus = Nothing
    , showErrors = False
    , showPassword = False
    , formState = Editing

    -- FIELDS VALUES
    , fieldEmail = ""
    , fieldPassword = ""
    , conf = conf
    , device = Window.Size 600 600
    }


defaultConfiguration : Configuration
defaultConfiguration =
    { negative = False
    , logo = Logo.ElmMulticolor
    , color = Warning
    , background = "images/back01.jpg"
    , title = "Sign in"
    , submitText = "Sign in"
    }


type alias Error =
    ( FormField, String )


type FormState
    = Editing
    | Fetching


type Msg
    = NoOp
    | SubmitForm
    | OnInput FormField String
    | Response (Result Http.Error String)
    | OnFocus FormField
    | OnLoseFocus FormField
    | ToggleShowPasssword
    | WindowSize Window.Size


type FormField
    = Email
    | Password


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        WindowSize wsize ->
            ( { model | device = wsize }, Cmd.none )

        SubmitForm ->
            case validate model of
                [] ->
                    ( { model | errors = [], response = Nothing, formState = Fetching }
                    , Http.send Response (postRequest model)
                    )

                errors ->
                    ( { model | errors = errors, showErrors = True }
                    , Cmd.none
                    )

        OnInput field value ->
            ( model
                |> setField field value
                |> setErrors
            , Cmd.none
            )

        Response (Ok response) ->
            ( { model | response = Just response, formState = Editing }, Cmd.none )

        Response (Err error) ->
            ( { model | response = Just (toString error), formState = Editing }, Cmd.none )

        OnFocus formField ->
            ( { model | focus = Just formField }, Cmd.none )

        OnLoseFocus formField ->
            ( { model | focus = Nothing }, Cmd.none )

        ToggleShowPasssword ->
            ( { model | showPassword = not model.showPassword }, Cmd.none )



-- HELPERS


setErrors : Model -> Model
setErrors model =
    case validate model of
        [] ->
            { model | errors = [] }

        errors ->
            { model | errors = errors }


setField : FormField -> String -> Model -> Model
setField field value model =
    case field of
        Email ->
            { model | fieldEmail = value }

        Password ->
            { model | fieldPassword = value }


postRequest : Model -> Http.Request String
postRequest model =
    let
        body =
            Json.Encode.object
                [ ( "email", Json.Encode.string model.fieldEmail )
                , ( "password", Json.Encode.string model.fieldPassword )
                ]
                |> Http.jsonBody
    in
    Http.request
        { method = "POST"
        , headers = []
        , url = "http://httpbin.org/post"
        , body = body
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False
        }


validate : Model -> List Error
validate =
    Validate.all
        [ .fieldEmail >> Validate.ifBlank ( Email, "Email can't be blank." )
        , .fieldPassword >> Validate.ifBlank ( Password, "Password can't be blank." )
        ]


onEnter : Msg -> Html.Attribute Msg
onEnter msg =
    Html.Events.keyCode
        |> Json.Decode.andThen
            (\key ->
                if key == 13 then
                    Json.Decode.succeed msg
                else
                    Json.Decode.fail "Not enter"
            )
        |> Html.Events.on "keyup"


content : Model -> FormField -> String
content model formField =
    case formField of
        Email ->
            model.fieldEmail

        Password ->
            model.fieldPassword



-- VIEWS


b1 : List (Element.Attribute msg)
b1 =
    [ Border.width 1
    , Border.color <| color Primary
    ]


viewInput : Model -> FormField -> String -> String -> Element Msg
viewInput model field inputType inputName =
    let
        errors =
            el [ height <| px 30, alignLeft ]
                (if model.showErrors then
                    model.errors
                        |> List.filter (\( fieldError, _ ) -> fieldError == field)
                        |> List.map (\( _, error ) -> text error)
                        |> paragraph []
                 else
                    text ""
                )

        value =
            content model field
    in
    column []
        [ Input.text
            [ Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
            , Border.color <| color GreyLighter
            , Background.color <|
                if model.conf.negative then
                    color GreyDark
                else
                    color White
            , paddingXY 0 4
            , Events.onFocus <| OnFocus field
            , Events.onLoseFocus <| OnLoseFocus field
            , Border.rounded 0
            , Element.htmlAttribute
                (if field == Email then
                    Html.Attributes.autofocus True
                 else
                    Html.Attributes.autofocus False
                )
            , below <| el [ Font.color <| color Primary ] errors
            ]
            { onChange = Just <| OnInput field
            , text = value
            , placeholder = Nothing
            , label =
                Input.labelAbove
                    []
                <|
                    el
                        ([ Hack.style ( "transition", "0.3s" )
                         , width shrink
                         , alignLeft
                         ]
                            ++ (if (model.focus /= Just field) && (value == "") then
                                    [ moveDown 26 ]
                                else
                                    [ scale 0.9
                                    , moveDown -2
                                    , moveLeft 3
                                    ]
                               )
                        )
                        (text inputName)
            }
        ]


view2 : Int -> Model -> Element Msg
view2 viewPort model =
    let
        fontColor =
            if model.conf.negative then
                color Light
            else
                color Grey

        paddingInsideBoxes =
            30

        maxWidthOfBoxesWhenTheyAreInColumnFormation =
            450

        maxWidthBoxOnTheLeft =
            maxWidthOfBoxesWhenTheyAreInColumnFormation

        maxWidthBoxOnTheRight =
            350

        twoBoxesInAColumnThatStopEnlarging =
            viewPort < maxWidthOfBoxesWhenTheyAreInColumnFormation + paddingInsideBoxes

        twoBoxesInAColumn =
            viewPort < 720

        twoBoxesInARowWithNarrowSpacing =
            viewPort < 940

        structure1 =
            if twoBoxesInAColumn then
                column [ spacing 20, width shrink, centerX ]
            else if twoBoxesInARowWithNarrowSpacing then
                row [ spacing 20, width shrink, centerX, centerY ]
            else
                row [ spacing 60, width shrink, centerX, centerY ]

        structure0 =
            if twoBoxesInAColumnThatStopEnlarging then
                row []
            else if twoBoxesInAColumn then
                row
                    [ width shrink
                    , Hack.style ( "min-width", toString maxWidthOfBoxesWhenTheyAreInColumnFormation ++ "px" )
                    , centerX
                    ]
            else
                row []

        commonAttr =
            [ htmlAttribute <| onEnter SubmitForm
            , Hack.style ( "box-shadow", "0px 3px 10px 2px rgba(0, 0, 0, 0.06)" )
            , if model.conf.negative then
                Background.color <| color GreyDark
              else
                Background.color <| color White
            , Font.color fontColor
            , padding paddingInsideBoxes
            , spacing 10
            ]

        extraAttr =
            if twoBoxesInAColumn then
                [ width fill
                , Hack.style ( "max-width", toString maxWidthOfBoxesWhenTheyAreInColumnFormation ++ "px" )
                ]
            else
                []
    in
    structure0
        [ structure1
            [ column
                ([ Hack.style ( "max-width", toString maxWidthBoxOnTheLeft ++ "px" )
                 , Border.widthEach { bottom = 0, left = 0, right = 0, top = 0 }
                 , Border.color <| color model.conf.color
                 ]
                    ++ commonAttr
                    ++ extraAttr
                )
                [ el
                    [ Font.size 24
                    , paddingXY 0 14
                    , alignLeft
                    ]
                  <|
                    text model.conf.title
                , viewInput model Email "text" "Email"
                , viewInput model Password "password" "Password"
                , paragraph [ Font.center, Font.size 14 ] [ text "Midway upon the journey of our life\nI found myself within a forest dark,\nFor the straightforward pathway had been lost." ]
                , el [ paddingXY 0 0 ]
                    (Framework.Button.button
                        ([ case model.conf.color of
                            Primary ->
                                Modifiers.Primary

                            Danger ->
                                Modifiers.Danger

                            Warning ->
                                Modifiers.Warning

                            Link ->
                                Modifiers.Link

                            _ ->
                                Modifiers.Primary
                         ]
                            ++ (if model.formState == Fetching then
                                    [ Modifiers.Loading ]
                                else
                                    []
                               )
                        )
                        (Just SubmitForm)
                        model.conf.submitText
                    )
                ]
            , column
                ([ Border.widthEach { bottom = 0, left = 0, right = 0, top = 0 }
                 , Border.color <| color model.conf.color
                 , Hack.style ( "max-width", toString maxWidthBoxOnTheRight ++ "px" )
                 ]
                    ++ commonAttr
                    ++ extraAttr
                )
                [ paragraph [ spacing 20 ]
                    [ el
                        [ Font.size 20
                        , paddingXY 0 14
                        , alignLeft
                        ]
                        (text "Midway upon the journey")
                    , el [] <| text "Ah me! how hard a thing it is to say\nWhat was this forest savage, rough, and stern,\nWhich in the very thought renews the fear."
                    , el [] <| text "So bitter is it, death is little more;\nBut of the good to treat, which there I found,\nSpeak will I of the other things I saw there."
                    , el
                        [ paddingXY 0 30
                        , centerX
                        , width shrink
                        ]
                        (Framework.Button.button
                            ([ case model.conf.color of
                                Primary ->
                                    Modifiers.Primary

                                Danger ->
                                    Modifiers.Danger

                                Warning ->
                                    Modifiers.Warning

                                Link ->
                                    Modifiers.Link

                                _ ->
                                    Modifiers.Primary
                             ]
                                ++ [ Modifiers.Outlined
                                   ]
                            )
                            Nothing
                            "Midway upon..."
                        )
                    ]
                ]
            ]
        ]


negativeLogo : Logo.Logo -> Logo.Logo
negativeLogo logo =
    case logo of
        Logo.ElmMulticolor ->
            Logo.ElmYellow

        Logo.Strawberry ->
            Logo.Strawberry

        Logo.Watermelon ->
            Logo.Watermelon

        _ ->
            Logo.ElmYellow


viewElement : Int -> Model -> Element Msg
viewElement viewPort model =
    column []
        [ el
            [ padding 20
            , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
            , if model.conf.negative then
                Border.color <| color Dark
              else
                Border.color <| color Light
            , if model.conf.negative then
                Background.color <| color Black
              else
                Background.color <| color White
            , width fill
            ]
          <|
            el [ alignLeft ] <|
                if model.conf.negative then
                    Logo.logo (negativeLogo model.conf.logo) 24
                else
                    Logo.logo model.conf.logo 24
        , el
            ([ width fill
             , height fill
             ]
                ++ (if model.conf.background /= "" then
                        [ Background.fittedImage model.conf.background ]
                    else
                        []
                   )
                ++ (if model.conf.negative then
                        [ Background.color <| color Dark ]
                    else
                        [ Background.color <| color White ]
                   )
            )
            (row
                [ width fill
                , padding 16
                , centerY
                ]
                [ view2 viewPort model
                ]
            )
        ]



-- SVG ICONS


svgHide : String -> Html msg
svgHide color =
    Svg.svg [ SA.viewBox "0 0 512 512", SA.height "32", SA.width "32" ]
        [ Svg.path
            [ SA.fill
                color
            , SA.d
                "M506 241l-89-89-14-13-258 258a227 227 0 0 0 272-37l89-89c8-8 8-22 0-30zM256 363a21 21 0 0 1 0-43c35 0 64-29 64-64a21 21 0 0 1 43 0c0 59-48 107-107 107zM95 152L6 241c-8 8-8 22 0 30l89 89 14 13 258-258c-86-49-198-37-272 37zm161 40c-35 0-64 29-64 64a21 21 0 0 1-43 0c0-59 48-107 107-107a21 21 0 0 1 0 43z"
            ]
            []
        ]


svgShow : String -> Html msg
svgShow color =
    Svg.svg [ SA.viewBox "0 0 512 512", SA.height "32", SA.width "32" ]
        [ Svg.path
            [ SA.fill
                color
            , SA.d
                "M256 192a64 64 0 1 0 0 128 64 64 0 0 0 0-128zm250 49l-89-89c-89-89-233-89-322 0L6 241c-8 8-8 22 0 30l89 89a227 227 0 0 0 322 0l89-89c8-8 8-22 0-30zM256 363a107 107 0 1 1 0-214 107 107 0 0 1 0 214z"
            ]
            []
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Window.resizes WindowSize



-- INIT


init : String -> ( Model, Cmd Msg )
init flag =
    ( initModel flag
    , Task.perform WindowSize Window.size
    )


view : Model -> Html Msg
view model =
    layoutWith
        { options =
            [ focusStyle
                { borderColor = Just <| color model.conf.color
                , backgroundColor = Nothing
                , shadow = Nothing
                }
            ]
        }
        [ Font.family
            [ Font.external
                { name = "Source Sans Pro"
                , url = "https://fonts.googleapis.com/css?family=Source+Sans+Pro"
                }
            , Font.sansSerif
            ]
        , Font.size 16
        , Font.color <| color GreyDark
        , Background.color <| color White
        ]
    <|
        viewElement model.device.width model


main : Program String Model Msg
main =
    {- `main` accept a flag that is a string containing a JSON configuration
       for the form
    -}
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
