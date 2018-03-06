port module Main exposing (main)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Element.Region as Area
import Framework.Button as Button
import Framework.Color as Color exposing (Color(..), color)
import Framework.Logo as Logo
import Framework.Spinner as Spinner
import Html
import Html.Events
import Http
import Json.Decode
import Json.Encode
import Navigation
import Pages.Form
import StyleElementsHack as Hack
import Styleguide
import UrlParser exposing ((</>))
import Window


version : String
version =
    "1.0.0"



-- ROUTES


routes : List Route
routes =
    [ Form
    , Editor

    --, Help
    , Styleguide
    ]


useHashInUrl : Bool
useHashInUrl =
    True


type Route
    = Form
    | Editor
    | Help
    | Styleguide
    | Debug
    | NotFound


type alias RouteData =
    { name : String
    , path : List String
    }


routeData : Route -> RouteData
routeData route =
    case route of
        Form ->
            { name = "Form"
            , path = [ "form" ]
            }

        Editor ->
            { name = "Editor"
            , path = []
            }

        Help ->
            { name = "Help"
            , path = [ "help" ]
            }

        Styleguide ->
            { name = "Style Guide"
            , path = [ "styleguide" ]
            }

        Debug ->
            { name = "Debug"
            , path = [ "debug" ]
            }

        NotFound ->
            { name = "Page Not Found"
            , path = []
            }


routeView : Route -> Model -> Element Msg
routeView route model =
    case route of
        Form ->
            Element.map MsgForm (Pages.Form.viewElement model.device.width model.modelForm)

        Editor ->
            viewEditor model

        Help ->
            viewHelp model

        Styleguide ->
            viewFramework model

        Debug ->
            viewDebug model

        NotFound ->
            text "Page not found"


routePath : Route -> List String
routePath route =
    .path <| routeData route


pathSeparator : String
pathSeparator =
    "/"


pathStarting : String
pathStarting =
    if useHashInUrl then
        "#/"
    else
        "/"


routePathJoined : Route -> String
routePathJoined route =
    pathStarting ++ String.join pathSeparator (routePath route)


routeName : Route -> String
routeName route =
    .name <| routeData route


matchers : UrlParser.Parser (Route -> a) a
matchers =
    let
        s =
            UrlParser.s
    in
    UrlParser.oneOf
        (List.map
            (\route ->
                let
                    listPath =
                        routePath route
                in
                if List.length listPath == 0 then
                    UrlParser.map route UrlParser.top
                else if List.length listPath == 1 then
                    UrlParser.map route (s (firstElement listPath))
                else if List.length listPath == 2 then
                    UrlParser.map route
                        (s (firstElement listPath)
                            </> s (secondElement listPath)
                        )
                else
                    UrlParser.map route UrlParser.top
            )
            routes
        )


locationToRoute : Navigation.Location -> Route
locationToRoute location =
    let
        parsedRoute =
            if useHashInUrl then
                UrlParser.parseHash matchers location
            else
                UrlParser.parsePath matchers location
    in
    case parsedRoute of
        Just route ->
            route

        Nothing ->
            NotFound



-- PORTS


type alias Flag =
    { localStorage : String
    , packVersion : String
    , width : Int
    , height : Int
    }


port urlChange : String -> Cmd msg


port sendValueToJsLocalStore : Maybe String -> Cmd msg


port onLocalStorageChange : (Json.Decode.Value -> msg) -> Sub msg



-- TYPES


type Msg
    = ChangeLocation String
    | UrlChange Navigation.Location
    | NewApiData (Result Http.Error DataFromApi)
    | FetchApiData String
    | FromJsLocalStoreToElm (Result String String)
    | WindowSize Window.Size
    | MsgStyleguide Styleguide.Msg
    | MsgForm Pages.Form.Msg
    | EditorChangeNegative Bool
    | EditorChangeTitle String
    | EditorChangeSubmitText String
    | EditorChangeBackground String
    | EditorChangeLogo Logo.Logo
    | EditorChangeColor Color
    | EditorChangeJson String
    | Response (Result Http.Error String)
    | ToggleFullscreen
    | ChangeConfiguration Pages.Form.Configuration
    | ChangeDevice DeviceType


type alias Model =
    { route : Route
    , history : List String
    , apiData : ApiData
    , location : Navigation.Location
    , title : String
    , localStorage : String
    , packVersion : String
    , fullscreen : Bool
    , modelStyleguide : Styleguide.Model
    , modelForm : Pages.Form.Model
    , configurations : List ( String, Pages.Form.Configuration )
    , device : Hack.Device
    , deviceType : DeviceType
    }


modelIntrospection : Model -> List ( String, String )
modelIntrospection model =
    [ ( toString model.route, "route" )
    , ( toString model.history, "history" )
    , ( toString model.apiData, "apiData" )
    , ( toString model.location, "location" )
    , ( toString model.title, "title" )
    , ( toString model.localStorage, "localStorage" )
    , ( toString model.packVersion, "packVersion" )
    , ( toString model.device, "device" )
    ]


type ApiData
    = NoData
    | Fetching
    | Fetched String


type DeviceType
    = IPhone5
    | IPhone7
    | IPhoneX
    | IPad



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        conf =
            model.modelForm.conf
    in
    case msg of
        ChangeDevice deviceType ->
            ( { model | deviceType = deviceType }, Cmd.none )

        MsgForm msg ->
            let
                ( newModel, newCmd ) =
                    Pages.Form.update msg model.modelForm
            in
            ( { model | modelForm = newModel }, Cmd.map MsgForm newCmd )

        MsgStyleguide msg ->
            let
                ( newStyleguideModel, newStyleguideCmd ) =
                    Styleguide.update msg model.modelStyleguide
            in
            ( { model | modelStyleguide = newStyleguideModel }, Cmd.none )

        ToggleFullscreen ->
            ( { model | fullscreen = not model.fullscreen }, Cmd.none )

        ChangeLocation location ->
            ( model, Navigation.newUrl location )

        UrlChange location ->
            let
                newRoute =
                    locationToRoute location

                newHistory =
                    location.pathname :: model.history

                newTitle =
                    routeName newRoute ++ " - " ++ model.title
            in
            ( { model | route = newRoute, history = newHistory, location = location }
            , urlChange newTitle
            )

        NewApiData result ->
            case result of
                Ok data ->
                    ( { model | apiData = Fetched data.origin }, Cmd.none )

                Err data ->
                    ( { model | apiData = Fetched <| toString data }, Cmd.none )

        FetchApiData url ->
            ( { model | apiData = Fetching }
            , Http.send NewApiData (Http.get url apiDecoder)
            )

        FromJsLocalStoreToElm result ->
            case result of
                Ok newConfString ->
                    let
                        modelForm =
                            model.modelForm

                        oldConf =
                            modelForm.conf

                        newConf =
                            updateConf newConfString oldConf

                        newModelForm =
                            { modelForm | conf = newConf }
                    in
                    ( { model
                        | localStorage = newConfString
                        , modelForm = newModelForm
                      }
                    , Cmd.none
                    )

                Err value ->
                    ( model, Cmd.none )

        WindowSize wsize ->
            ( { model | device = classifyDevice <| wsize }, Cmd.none )

        EditorChangeNegative value ->
            let
                newConf =
                    { conf | negative = value }
            in
            handleNewConfiguration model newConf

        EditorChangeLogo value ->
            let
                newConf =
                    { conf | logo = value }
            in
            handleNewConfiguration model newConf

        EditorChangeColor value ->
            let
                newConf =
                    { conf | color = value }
            in
            handleNewConfiguration model newConf

        EditorChangeTitle value ->
            let
                newConf =
                    { conf | title = value }
            in
            handleNewConfiguration model newConf

        EditorChangeSubmitText value ->
            let
                newConf =
                    { conf | submitText = value }
            in
            handleNewConfiguration model newConf

        EditorChangeBackground value ->
            let
                newConf =
                    { conf | background = value }
            in
            handleNewConfiguration model newConf

        EditorChangeJson newConfString ->
            let
                oldConf =
                    model.modelForm.conf

                newConf =
                    updateConf newConfString oldConf
            in
            handleNewConfiguration model newConf

        ChangeConfiguration newConf ->
            handleNewConfiguration model newConf

        Response (Ok response) ->
            ( model, Cmd.none )

        Response (Err error) ->
            ( model, Cmd.none )


handleNewConfiguration : Model -> Pages.Form.Configuration -> ( Model, Cmd msg )
handleNewConfiguration model newConf =
    let
        modelForm =
            model.modelForm

        conf =
            modelForm.conf

        newModelForm =
            { modelForm | conf = newConf }

        newLocalStorage =
            Json.Encode.encode 0 <| Pages.Form.confEncoder newConf
    in
    ( { model
        | modelForm = newModelForm
        , localStorage = newLocalStorage
      }
    , Cmd.batch [ sendValueToJsLocalStore <| Just newLocalStorage ]
    )



-- INIT


initModel : Flag -> Navigation.Location -> Model
initModel flag location =
    { route = locationToRoute location
    , history = [ location.pathname ]
    , apiData = NoData
    , location = location
    , title = "Elm Pages Editor"
    , localStorage = flag.localStorage
    , packVersion = flag.packVersion
    , device = classifyDevice <| Window.Size flag.width flag.height
    , deviceType = IPhone7
    , fullscreen = False
    , modelStyleguide =
        [ ( Logo.introspection, True )
        , ( Button.introspection, True )
        , ( Spinner.introspection, True )
        , ( Color.introspection, True )
        ]
    , modelForm = Pages.Form.initModel flag.localStorage
    , configurations =
        [ ( "Page 1"
          , { negative = False
            , logo = Logo.ElmMulticolor
            , color = Color.Link
            , background = "images/back01.jpg"
            , title = "Sign in"
            , submitText = "Sign in"
            }
          )
        , ( "Page 2"
          , { negative = False
            , logo = Logo.Watermelon
            , color = Danger
            , background = "images/back02.jpg"
            , title = "Sign in"
            , submitText = "Sign in"
            }
          )
        , ( "Page 3"
          , { negative = True
            , logo = Logo.ElmMulticolor
            , color = Color.Warning
            , background = "images/back03.jpg"
            , title = "Sign in"
            , submitText = "Sign in"
            }
          )
        , ( "Default"
          , Pages.Form.defaultConfiguration
          )
        ]
    }


initCmd : Model -> Navigation.Location -> Cmd Msg
initCmd model location =
    Cmd.batch
        -- [ Task.perform WindowSize Window.size ]
        []


init : Flag -> Navigation.Location -> ( Model, Cmd Msg )
init flag location =
    let
        model =
            initModel flag location

        cmd =
            initCmd model location
    in
    ( model, cmd )


updateConf :
    String
    -> Pages.Form.Configuration
    -> Pages.Form.Configuration
updateConf newConfString oldConf =
    let
        result =
            Json.Decode.decodeString Pages.Form.confDecoder newConfString
    in
    case result of
        Ok newConf ->
            newConf

        Err err ->
            let
                _ =
                    Debug.log "Error parsin local store" err
            in
            oldConf



-- API DECODER


type alias DataFromApi =
    { origin : String
    , data : String
    }


apiDecoder : Json.Decode.Decoder DataFromApi
apiDecoder =
    Json.Decode.map2 DataFromApi
        (Json.Decode.at [ "origin" ] Json.Decode.string)
        (Json.Decode.at [ "data" ] Json.Decode.string)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map FromJsLocalStoreToElm <| onLocalStorageChange (Json.Decode.decodeValue Json.Decode.string)
        , Window.resizes WindowSize
        ]



-- VIEWS
{-
   <style>
       body {
           -webkit-transition: opacity .2s;
           transition: opacity .2s
       }

       body.urlChange {
           opacity: .5;
           -webkit-transition: opacity 0s;
           transition: opacity 0s
       }
   </style>

-}


genericSpaceFromSide : number
genericSpaceFromSide =
    16


view : Model -> Html.Html Msg
view model =
    layoutWith
        { options =
            [ focusStyle
                { borderColor = Just <| color model.modelForm.conf.color
                , backgroundColor = Nothing
                , shadow = Nothing
                }
            ]
        }
        [ Font.family
            [ Font.typeface "Source Sans Pro"
            , Font.sansSerif
            ]
        , Font.size 16
        , Font.color <| color GreyDark
        , Background.color <| color White
        , viewMenuStickyRight (viewSubMenuRight model) model
        ]
    <|
        if model.route == Form then
            routeView Form model
        else if model.device.width < 590 then
            viewApp model
        else
            viewTwoColumnsView model


viewTwoColumnsView : Model -> Element Msg
viewTwoColumnsView model =
    let
        commonAttr =
            [ Hack.style ( "max-height", "100vh" )
            , Hack.style ( "max-width", "100vw" )
            , scrollbars
            , alignTop
            ]

        withoutDeviceFrame =
            model.device.width < 740

        portionLeft =
            if withoutDeviceFrame then
                1
            else
                3

        portionRight =
            if withoutDeviceFrame then
                1
            else
                2

        widthLeft =
            floor (toFloat model.device.width / (portionRight + portionLeft)) * portionLeft
    in
    row []
        [ row
            (commonAttr
                ++ [ Background.color <| color Grey
                   , Border.widthEach { top = 0, left = 0, bottom = 0, right = 1 }
                   , Background.color <| color Grey
                   , width <| fillPortion portionLeft
                   ]
            )
          <|
            [ column
                [ paddingXY 0 0
                , spacing 50
                ]
                (if withoutDeviceFrame then
                    [ Element.map MsgForm (Pages.Form.viewElement widthLeft model.modelForm)
                    ]
                 else
                    [ viewDeviceFrame model
                    , viewApiResponse model
                    ]
                )
            ]
        , row
            (commonAttr
                ++ [ width <| fillPortion portionRight ]
            )
            [ viewApp model
            ]
        ]


viewApiResponse : Model -> Element msg
viewApiResponse model =
    row
        [ paddingXY genericSpaceFromSide genericSpaceFromSide
        , width fill
        ]
        [ Input.multiline
            [ height <| px 300
            , centerX
            , width <| px 320

            -- cols are for Safari
            --, Element.attribute <| Html.Attributes.cols 40
            , Font.color <| color Black
            , Background.color <| color GreyLight
            , Border.width 10
            , Border.color <| color Dark
            , Border.rounded 20
            , Hack.style ( "box-shadow", "rgba(10, 10, 10, 0.19) 5px 5px 5px 5px" )
            ]
            { onChange = Nothing
            , text = Maybe.withDefault "API answer" model.modelForm.response
            , placeholder = Nothing
            , label = Input.labelAbove [] <| text ""
            , spellcheck = True
            }
        ]


viewApp : Model -> Element Msg
viewApp model =
    column []
        [ column [ height shrink ]
            [ viewHeader model

            --, viewMenu model
            ]
        , column []
            [ row [ width fill ]
                [ if model.route == Form then
                    column []
                        [ viewDeviceFrame model
                        ]
                  else
                    column
                        [ padding 16
                        , Hack.style ( "max-width", "600px" )
                        ]
                        [ routeView model.route model
                        ]
                ]
            ]
        ]


viewDeviceFrame : Model -> Element Msg
viewDeviceFrame model =
    let
        deviceBorderTop =
            80

        deviceBorderBottom =
            110

        deviceBorderSide =
            10

        ( deviceWidth, deviceHeight ) =
            case model.deviceType of
                IPhone5 ->
                    ( 320, 568 )

                IPhone7 ->
                    ( 375, 667 )

                IPhoneX ->
                    ( 375, 812 )

                IPad ->
                    ( 768, 1024 )
    in
    column
        [ height shrink
        , width shrink
        , centerX
        , alignTop
        , above <|
            el
                [ Font.shadow { offset = ( -2, -2 ), blur = 0, color = color Black }
                , Font.shadow { offset = ( 2, 2 ), blur = 0, color = color GreyDark }
                , Font.color <| color Dark
                , moveDown 80
                , Font.size 48
                , centerX
                ]
                (text "● ▬▬▬")
        , below <|
            el
                [ Font.shadow { offset = ( -2, -2 ), blur = 0, color = color Black }
                , Font.shadow { offset = ( 2, 2 ), blur = 0, color = color GreyDark }
                , Font.color <| color Dark
                , moveUp 180
                , Font.size 150
                , centerX
                ]
                (text "●")
        ]
        [ column
            [ padding 16
            ]
            [ el
                [ height <| px (2 + deviceHeight + deviceBorderTop + deviceBorderBottom)
                , width <| px (2 + deviceWidth + deviceBorderSide * 2)
                , Border.widthEach
                    { top = deviceBorderTop
                    , right = deviceBorderSide
                    , bottom = deviceBorderBottom
                    , left = deviceBorderSide
                    }
                , Border.rounded 50
                , Border.color <| color BlackTer
                , Hack.style ( "box-shadow", "rgba(10, 10, 10, 0.19) 5px 5px 5px 5px" )
                ]
              <|
                el
                    [ width fill
                    , scrollbars
                    , Border.width 1
                    , Border.color <| color Black
                    ]
                    (Element.map MsgForm (Pages.Form.viewElement deviceWidth model.modelForm))
            ]
        ]


viewLinkMenu : Model -> Route -> Element Msg
viewLinkMenu model route =
    let
        url =
            routePathJoined route

        common =
            if model.device.width < menuBreakPoint then
                [ padding 10
                , width fill
                ]
            else
                [ padding 10
                ]
    in
    if model.route == route then
        el
            ([ Background.color <| color White
             , Font.color <| color Black
             ]
                ++ common
            )
            (text <| routeName route)
    else
        myLink common
            { url = url
            , label = text <| routeName route
            }


myLink :
    List (Attribute Msg)
    -> { label : Element Msg, url : String }
    -> Element Msg
myLink attr param =
    link
        (attr
            ++ (if useHashInUrl then
                    [ onLinkClick param.url ]
                else
                    []
               )
        )
        param


viewMenu : Model -> Element Msg
viewMenu model =
    let
        menuList =
            List.map
                (\route -> viewLinkMenu model route)
                routes

        type_ =
            if model.device.width < menuBreakPoint then
                column
            else
                row
    in
    type_
        [ Background.color <| color Primary
        , Font.color <| color White
        ]
        menuList


viewHeader : Model -> Element Msg
viewHeader model =
    column
        [ paddingEach { top = 40, left = 20, bottom = 0, right = 20 }
        , spacing 5
        ]
        [ h1
            [ centerX
            , Font.color <| color Black
            , Font.size 32
            , padding 0
            ]
          <|
            row [ spacing 10 ]
                [ Logo.logo Logo.Pencil 24
                , el
                    [ Font.color <| color GreyLight
                    , Font.bold
                    ]
                  <|
                    text model.title
                ]
        , paragraph []
            [ text "This is a proof of concept written using Elm and style-elements." ]
        , paragraph []
            [ text "This combination create a level of abstraction on top of Html/CSS/Javascript to quickly create reliable web apps just writing Elm+Style-Elements." ]
        , paragraph []
            [ text "Post: "
            , link
                [ Font.color <| color Primary ]
                { url = "https://medium.com/@l.mugnaini/is-the-future-of-front-end-development-without-html-css-and-javascript-e7bb0877980e", label = text "Is the future of front-end development without Html CSS and Javascript?" }
            ]
        , paragraph []
            [ text "More info and source code at "
            , link
                [ Font.color <| color Primary ]
                { url = "https://github.com/lucamug/elm-pages-editor.git", label = text "https://github.com/lucamug/elm-pages-editor.git" }
            ]
        , text <| "Version " ++ version
        ]


viewMenuStickyRight : List (Element msg) -> Model -> Attribute msg
viewMenuStickyRight menuItems model =
    above <|
        row
            [ Hack.style ( "opacity", "0.7" )
            , Hack.style ( "position", "fixed" )
            , Hack.style ( "right", "0" )
            , Hack.style ( "bottom", "auto" )
            , Background.color <| color White
            , pointer
            , padding 6
            , spacing 12
            , width shrink
            ]
        <|
            menuItems


viewSubMenuRight : Model -> List (Element Msg)
viewSubMenuRight model =
    List.map
        (\( name, conf ) -> el [ Events.onClick <| ChangeConfiguration conf ] <| text name)
        model.configurations
        ++ (if model.route == Form then
                []
            else
                viewDeviceMenu
           )
        ++ [ myLink [] <| { label = text "Styleguide", url = pathStarting ++ "styleguide" } ]
        ++ [ myLink [] <| { label = Logo.logo Logo.Pencil 18, url = pathStarting } ]
        ++ [ el []
                (if model.route == Form then
                    myLink []
                        { label = Logo.logo Logo.ExitFullscreen 18
                        , url = pathStarting
                        }
                 else
                    myLink []
                        { label = Logo.logo Logo.Fullscreen 18
                        , url = pathStarting ++ "form"
                        }
                )
           ]


viewDeviceMenu : List (Element Msg)
viewDeviceMenu =
    [ el [ pointer, Events.onClick <| ChangeDevice IPhone5 ] <| text "iPhone 5"
    , el [ pointer, Events.onClick <| ChangeDevice IPhone7 ] <| text "iPhone 7"
    , el [ pointer, Events.onClick <| ChangeDevice IPhoneX ] <| text "iPhone X"

    --, el [ pointer, Events.onClick <| ChangeDevice IPad ] <| text "iPad"
    ]


menuBreakPoint : Int
menuBreakPoint =
    320


viewFooter : Model -> Element msg
viewFooter model =
    let
        element =
            if model.device.width < menuBreakPoint then
                column
            else
                row
    in
    element
        [ spaceEvenly
        , Background.color <| color GreyDarker
        , Font.color <| color WhiteTer
        , padding 30
        ]
        [ el [] <|
            text <|
                "ver. "
                    ++ model.packVersion
        ]


onLinkClick : String -> Attribute Msg
onLinkClick url =
    htmlAttribute
        (Html.Events.onWithOptions "click"
            { stopPropagation = False
            , preventDefault = True
            }
            (Json.Decode.succeed (ChangeLocation url))
        )


viewDebug : Model -> Element msg
viewDebug model =
    column []
        (List.map
            (\( item, name ) ->
                column []
                    [ h3 [] <| text <| "► " ++ name
                    , paragraph
                        [ Background.color <| color GreyLight
                        , padding 10
                        ]
                        (List.map (\line -> paragraph [] [ text <| line ]) <| String.split "," item)
                    ]
            )
         <|
            modelIntrospection model
        )


viewEditor : Model -> Element Msg
viewEditor model =
    column [ spacing 30 ]
        [ h3 [] <| text "Editor"
        , paragraph []
            [ Input.checkbox []
                { label = Input.labelAbove [] <| text "Negative"
                , onChange = Just EditorChangeNegative
                , checked = model.modelForm.conf.negative
                , icon = Nothing
                }
            ]
        , Input.radio []
            { label = Input.labelAbove [] <| text "Logo"
            , onChange = Just EditorChangeLogo
            , selected = Just model.modelForm.conf.logo
            , options =
                [ Input.option Logo.ElmMulticolor (el [ padding 10, alignLeft ] (Logo.logo Logo.ElmMulticolor 22))
                , Input.option Logo.Watermelon (el [ padding 10, alignLeft ] (Logo.logo Logo.Watermelon 22))
                , Input.option Logo.Strawberry (el [ padding 10, alignLeft ] (Logo.logo Logo.Strawberry 22))
                ]
            }
        , Input.radio []
            { label = Input.labelAbove [] <| text "Color"
            , onChange = Just EditorChangeColor
            , selected = Just model.modelForm.conf.color
            , options =
                [ Input.option Primary (row [ padding 10, spacing 20 ] [ el [ alignLeft, Border.rounded 3, width <| px 50, height <| px 40, Background.color <| color Primary ] <| text "", text "Primary" ])
                , Input.option Danger (row [ padding 10, spacing 20 ] [ el [ alignLeft, Border.rounded 3, width <| px 50, height <| px 40, Background.color <| color Danger ] <| text "", text "Danger" ])
                , Input.option Warning (row [ padding 10, spacing 20 ] [ el [ alignLeft, Border.rounded 3, width <| px 50, height <| px 40, Background.color <| color Warning ] <| text "", text "Warning" ])
                , Input.option Color.Link (row [ padding 10, spacing 20 ] [ el [ alignLeft, Border.rounded 3, width <| px 50, height <| px 40, Background.color <| color Color.Link ] <| text "", text "Link" ])
                ]
            }
        , Input.text
            []
            { label = Input.labelAbove [] <| text "Title"
            , onChange = Just EditorChangeTitle
            , placeholder = Nothing
            , text = model.modelForm.conf.title
            }
        , Input.text
            []
            { label = Input.labelAbove [] <| text "Submit button"
            , onChange = Just EditorChangeSubmitText
            , placeholder = Nothing
            , text = model.modelForm.conf.submitText
            }
        , Input.text
            []
            { label = Input.labelAbove [] <| text "Background"
            , onChange = Just EditorChangeBackground
            , placeholder = Nothing
            , text = model.modelForm.conf.background
            }
        , column []
            [ h3 [] <| text "Configuration"
            , Input.multiline
                [ height <| px 200
                ]
                { onChange = Just EditorChangeJson
                , text = Json.Encode.encode 4 (Pages.Form.confEncoder model.modelForm.conf)
                , placeholder = Nothing
                , label = Input.labelAbove [] <| text ""
                , spellcheck = True
                }
            ]
        ]


viewHelp : Model -> Element Msg
viewHelp model =
    column [ spacing 20 ]
        [ paragraph []
            [ text "Elm Pages Editor. "
            , link [ Font.color <| color Primary ] { url = "https://github.com/lucamug/elm-pages-editor.git", label = text "https://github.com/lucamug/elm-pages-editor.git" }
            , text "."
            ]
        ]


viewFramework : Model -> Element Msg
viewFramework model =
    column []
        [ Styleguide.viewSections model.modelStyleguide |> Element.map MsgStyleguide
        ]



-- HELPERS


firstElement : List String -> String
firstElement list =
    Maybe.withDefault "" (List.head list)


secondElement : List String -> String
secondElement list =
    firstElement (Maybe.withDefault [] (List.tail list))



-- MAIN


main : Program Flag Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


header :
    number
    -> List (Element.Attribute msg)
    -> Element.Element msg
    -> Element.Element msg
header level attributes child =
    let
        fontLevel =
            abs (level - 4)

        fontSize =
            scaledFontSize fontLevel

        pd =
            floor (toFloat fontSize / 2)
    in
    Element.el
        ([ Area.heading level
         , Font.size fontSize
         , paddingEach { top = pd, right = 0, bottom = pd, left = 0 }
         , alignLeft
         , Font.bold
         ]
            ++ attributes
        )
        child


h1 : List (Element.Attribute msg) -> Element.Element msg -> Element.Element msg
h1 =
    header 1


h2 : List (Element.Attribute msg) -> Element.Element msg -> Element.Element msg
h2 =
    header 2


h3 : List (Element.Attribute msg) -> Element.Element msg -> Element.Element msg
h3 =
    header 3



{-
   goldenRatio : Float
   goldenRatio =
       1.618
-}


genericRatio : Float
genericRatio =
    1.4


scaledFontSize : Int -> Int
scaledFontSize n =
    round (16 * (genericRatio ^ toFloat n))
