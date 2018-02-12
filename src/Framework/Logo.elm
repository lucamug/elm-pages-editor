module Framework.Logo
    exposing
        ( Logo(..)
        , introspection
        , logo
        )

{-| Logos generator

Check [Style Guide](https://lucamug.github.io/elm-style-framework/) to see usage examples.


# Functions

@docs Logo, spinner, introspection

-}

import Color
import Element
import Framework.Color
import Html exposing (Html)
import Html.Attributes
import Styleguide
import Svg exposing (..)
import Svg.Attributes as SA exposing (..)


{-| Used to generate the [Style Guide](https://lucamug.github.io/elm-style-framework/)
-}
introspection : Styleguide.Introspection msg
introspection =
    { name = "Logos"
    , signature = "logo : Logo -> Int -> Color.Color -> Element.Element msg"
    , description = "List of SVG logos"
    , usage = "logo Pencil 48"
    , usageResult = logo Pencil 48
    , boxed = True
    , types =
        [ ( "Logos"
          , [ ( logo ElmMulticolor 32, "logo ElmMulticolor 32" )
            , ( logo ElmYellow 32, "logo ElmYellow 32" )
            , ( logo ElmWhite 32, "logo ElmWhite 32" )
            , ( logo Cocacola 32, "logo Cocacola 32" )
            , ( logo Pencil 32, "logo ExitFullscreen 32" )
            , ( logo ExitFullscreen 32, "logo ExitFullscreen 32" )
            , ( logo Fullscreen 32, "logo Fullscreen 32" )
            ]
          )
        ]
    }


{-| SVG Logo
-}
logo : Logo -> Int -> Element.Element msg
logo logo size =
    Element.html <|
        case logo of
            Pencil ->
                pencil size

            ElmMulticolor ->
                logoElm size Colorful

            ElmYellow ->
                logoElm size (Color Yellow)

            ElmWhite ->
                logoElm size (Color White)

            ExitFullscreen ->
                exitFullscreen size

            Fullscreen ->
                fullscreen size

            Cocacola ->
                logoCoke "red" size


{-| Type of logos
-}
type Logo
    = Pencil
    | ExitFullscreen
    | Fullscreen
    | ElmMulticolor
    | ElmYellow
    | ElmWhite
    | Cocacola


pencil : Int -> Html.Html msg
pencil size =
    Svg.svg [ Html.Attributes.style [ ( "height", toString size ++ "px" ) ], viewBox "0 0 529 529" ]
        [ Svg.path [ d "M329 89l107 108-272 272L57 361 329 89zm189-26l-48-48a48 48 0 0 0-67 0l-46 46 108 108 53-54c14-14 14-37 0-52zM0 513c-2 9 6 16 15 14l120-29L27 391 0 513z" ] []
        ]


exitFullscreen : Int -> Html.Html msg
exitFullscreen size =
    Svg.svg [ Html.Attributes.style [ ( "height", toString size ++ "px" ) ], viewBox "0 0 32 32" ]
        [ Svg.path [ fill "#030104", d "M25 27l4 5 3-3-5-4 5-5H20v12zM0 12h12V0L7 5 3 0 0 3l5 4zm0 17l3 3 4-5 5 5V20H0l5 5zm20-17h12l-5-5 5-4-3-3-4 5-5-5z" ] []
        ]


fullscreen : Int -> Html.Html msg
fullscreen size =
    Svg.svg [ Html.Attributes.style [ ( "height", toString size ++ "px" ) ], viewBox "0 0 533 533" ]
        [ Svg.path [ d "M533 0v217l-83-84-100 100-50-50L400 83 317 0h216zM233 350L133 450l84 83H0V317l83 83 100-100 50 50z" ] []
        ]


type ElmLogoType
    = Color ElmLogoColor
    | Colorful


type ElmLogoColor
    = Orange
    | Green
    | LightBlue
    | Blue
    | White
    | Black
    | Yellow


elmLogoColors : ElmLogoColor -> Color.Color
elmLogoColors color =
    case color of
        Orange ->
            Color.rgb 0xF0 0xAD 0x00

        Yellow ->
            Color.rgb 0xF0 0xAD 0x00

        Green ->
            Color.rgb 0x7F 0xD1 0x3B

        LightBlue ->
            Color.rgb 0x60 0xB5 0xCC

        Blue ->
            Color.rgb 0x5A 0x63 0x78

        White ->
            Color.rgb 0xFF 0xFF 0xFF

        Black ->
            Color.rgb 0x00 0x00 0x00


logoElm : Int -> ElmLogoType -> Html msg
logoElm height type_ =
    let
        f =
            SA.fill

        d =
            SA.d

        p =
            Svg.path

        c =
            case type_ of
                Colorful ->
                    { c1 = elmLogoColors Orange
                    , c2 = elmLogoColors Green
                    , c3 = elmLogoColors LightBlue
                    , c4 = elmLogoColors Blue
                    }

                Color c ->
                    { c1 = elmLogoColors c
                    , c2 = elmLogoColors c
                    , c3 = elmLogoColors c
                    , c4 = elmLogoColors c
                    }
    in
    Svg.svg
        [ SA.version "1"
        , SA.viewBox "0 0 323 323"
        , SA.height <| toString height
        , SA.width <| toString <| floor <| toFloat height * 1
        ]
        [ p [ f (Framework.Color.colorToHex c.c1), d "M162 153l70-70H92zm94 94l67 67V179z" ] []
        , p [ f (Framework.Color.colorToHex c.c2), d "M9 0l70 70h153L162 0zm238 85l77 76-77 77-76-77z" ] []
        , p [ f (Framework.Color.colorToHex c.c3), d "M323 144V0H180zm-161 27L9 323h305z" ] []
        , p [ f (Framework.Color.colorToHex c.c4), d "M153 162L0 9v305z" ] []
        ]


logoCoke : String -> Int -> Html.Html msg
logoCoke color height =
    let
        ratio =
            -- Width / Height
            202 / 67.5

        c =
            case color of
                "red" ->
                    "#f40009"

                "white" ->
                    "#fff"

                _ ->
                    "#000"

        f =
            SA.fill

        d =
            SA.d

        p =
            Svg.path
    in
    Svg.svg
        [ SA.version "1"
        , SA.viewBox "0 0 202 67.5"
        , SA.height <| toString height
        , SA.width <| toString <| floor <| toFloat height * ratio
        ]
        [ p [ f c, d "M168.1 56.8l-.6.6c-.9.8-1.8 1.6-2.9 1.2-.3-.1-.5-.5-.5-.8 0-2.3 1-4.4 2-6.4l.2-.5c2.8-4.8 6-10.3 10.9-14.2.8-.6 1.7-1 2.6-.7.2.2.5.6.5 1l-.2.4-3.8 6.7c-2.5 4.3-5 8.8-8.2 12.7zm-26.1-11c-.2 0-3.5-1-4.1-4-.5-2.7 1.3-4.7 3-5.7a3 3 0 0 1 2.7-.5c.7.5 1 1.4 1 2.4l-.2 1.8v.1c-.6 2-1.4 4-2.4 5.8zM129.5 58a3 3 0 0 1-.4-1.6c-.1-3.6 3.8-10 6.5-13.5 1.1 2.5 3.7 4 5.3 4.7-2 4.4-8.6 13.6-11.4 10.4zm47 .6c-.6.5-1.5.1-1.1-.9.8-2.5 4.2-7.8 4.2-7.8l9.3-16.5h-6.4l-1 1.6a8.8 8.8 0 0 0-1.5-1.8c-1.6-1-3.9-.5-5.4.3-7 4-12 12-16 18.2 0 0-4 7-6.4 7.4-1.8.2-1.6-2.2-1.5-2.8.7-4.1 2.3-8 4-11.5A105.8 105.8 0 0 0 180 19c-.1 0-1.1.2-2.3.2-5.7 8-17.5 19.7-21 21.4 1.5-3.8 11.7-22 20.4-30.6l1.4-1.4c2.1-2 4.3-4.1 6-4.5.2 0 .4 0 .6.4.1 1.6-.5 2.8-1.2 4.2l-1 2 2.3-.6c1-2 2.2-4.1 1.8-6.8a2 2 0 0 0-1.6-1.6c-2.6-.5-5.4 1.4-7.7 3a110.1 110.1 0 0 0-30.3 40.5c-.6.4-3 1-3.4.7.8-1.7 1.9-4 2.4-6.6l.2-2.3c0-1.5-.4-3-1.8-4-1.6-.9-3.7-.5-5 .1-6.2 2.6-10.8 9-14.2 14.2a31 31 0 0 0-4 10.9c-.4 3.2.3 5.2 2.1 6.2 1.9 1 4.2 0 5.1-.5A39.1 39.1 0 0 0 143 48c.2 0 2 0 3.5-.4l-.8 2.5c-2.2 6.4-3.2 10.8-1.1 13.4 3 3.6 7.8-.2 11.8-5.1-.9 6 2.2 6.9 4.6 6.4 2.7-.7 5.7-3.6 7-5.1-.4 1.7-.2 4.9 2.2 5.2 1.7.3 3-.6 4.4-1.4a50.4 50.4 0 0 0 13.2-15.1h-2.2c-2.3 3.5-5.2 8-9 10.2zM95.9 23.1h6l3.4-5.5h-6zm95.9-14.6a24.4 24.4 0 0 1-15.1 3.7 88 88 0 0 0-4.6 5.5c8 2 16.6-2.5 21.4-6.8 5-4.4 7.6-9.9 7.6-9.9s-3.8 4.3-9.3 7.5zM141.2 7c-1 11-9.5 17.4-11.6 17.9-1.2.2-3.4-.3-1.5-5a30.5 30.5 0 0 1 13-14l.1 1.1zm-16.6 27.6c-.6-1.3-2-2.2-3.6-2-5 .4-9.9 4.5-12.4 10.4-1.4 3-2.1 5.5-2.6 9.5 1.5-1.8 4.7-4.7 8.3-6.3 0 0 .5-3.8 3-7.3 1-1.4 2.9-3.6 5-3 1.8.6 1.2 5.7-1.3 10.7a34.5 34.5 0 0 1-7.4 9.9c-2.5 2-6.2 4.6-9.5 2.7-2-1.2-3-3.8-2.8-7 1-9.3 5.2-17.1 11.2-26.1 6.2-8.3 13-16.9 22.2-21.4 2-1 3.7-1.2 5.2-.6 0 0-8.7 4.8-12.8 13.6-1 2.2-2.5 5.2-1 7.9.7 1.4 2 1.5 3.2 1.4 5-1.2 8.3-5.9 11-10.2A23.8 23.8 0 0 0 143 5.3c2.4-1.3 7.4 1 7.4 1 3.9 1.2 12.1 7.6 14.9 8.8 1.3-1.6 3.6-4 4.8-5.2l-1.8-1.1c-2.9-1.8-6-3.5-9-5.1A18 18 0 0 0 144 2.3l-2.2.7c-2-2.3-5.5-2-8-1.4-9.3 2.6-17.8 9-27 20.2a73.8 73.8 0 0 0-13 23.7c-1.7 5-2.3 12.4 2 16.7 3.5 3.7 8.2 3 11.5 1.6a36.7 36.7 0 0 0 17-20c.7-2.6 1.6-6.3.2-9.1zm-79.9-8.5L43.5 29h-1.3c-1.7-.6-3-1.8-3.4-3.1-.5-2.6 1.7-4.7 2.7-5.5 1-.6 2.4-1 3.3-.3.5.6.7 1.4.7 2.3 0 1.2-.3 2.5-.8 3.8zm-2.6 5.3v.2l-2.8 4.5c-1.7 2.2-3.7 5-6.3 6.3-.8.3-1.8.4-2.4-.2-1.1-1.4-.5-3.3 0-4.9l.1-.5a45.5 45.5 0 0 1 5.8-10.1 9.1 9.1 0 0 0 5.7 4.3v.4zm34.4-3c1.2-1.7 4.8-6.2 5.7-7 3-2.6 4.1-1.4 4.2-.6a578.7 578.7 0 0 1-10 17 14 14 0 0 1-4.9 5c-.3.1-.8.1-1.1-.1-.4-.3-.6-.8-.6-1.2.2-1.6 1.8-6.4 6.7-13zm-30.4-11c-3.8-2.5-11.5 2.3-17.6 10.4-5.6 7.4-8 15.9-5.3 19.8 3.9 4.6 11.1-2.1 14.2-5.7l.4-.4c2-2.3 3.7-5 5.3-7.6l1.5-2.5c.9-.1 2-.4 3.1-.8 0 .1-4.6 7.8-4.1 11.7.1 1.2 0 5.4 4.2 6.7 5.6 1 10-3.3 14-7.2l1-1-.2.9c-1.7 5.7.5 6.9 2 7.3 4 1.2 9-4.8 9-4.8 0 1.9-.4 3.4 1.6 4.7 1.9.7 3.8-.3 5.2-1.3A54 54 0 0 0 93.3 33h-2.2s-5.3 7.8-8.8 9.4c0 0-.7.4-1 .1-.5-.4-.3-1.2 0-1.7l13.4-23.3h-6.3l-.8 1.2-.2-.3C83.5 13 74.6 21.4 68 31a63.5 63.5 0 0 1-9.3 11s-5 4.6-7.2 1.3a6.6 6.6 0 0 1 0-4.8A39.6 39.6 0 0 1 63.1 21c1.3-1 2.8-1.4 3.6-1 .7.5.8 1.6.4 2.3-1.2 0-2 .3-2.8 1-1.5 1.6-2 3-1.5 4.5 2.2 3.2 6.7-3.2 6.5-7 0-1.5-.8-2.8-2-3.4-1.6-1-4-.7-5.7 0-2.2.9-5.6 3.7-7.7 6-2.5 2.8-6.8 5.9-8.2 5.5.4-1.2 4.1-8.7.3-11.5zm31.7 40.7C70.4 53.3 60.3 52.5 44 57c-17.4 4-23.2 6.7-30.8 1.4-2.9-2.5-4-6.7-3.2-12.7a64.4 64.4 0 0 1 15.5-29.5c4.8-5.4 9.3-10 15.3-12 4.5-1.1 4.1 2.5 3.6 3-.6 0-1.6 0-2.4.6-.6.4-2.2 2-2.3 4-.2 3.2 3.1 2.5 4.5.8 1.5-2 3.8-5.7 2-9.2-.7-1.2-2-2.1-3.6-2.4a27 27 0 0 0-15.2 5.2 66.5 66.5 0 0 0-23 27.7C1.5 40.5-.9 49.8 2.7 57.4c2.9 5.3 8.7 8 15.6 7.5 4.9-.5 10.8-2.1 14.7-3 4-1 24.3-8 31 4.1 0 0 2.2-4.3 7.7-4.4a26 26 0 0 1 15.9 4.9c-1.6-2.4-6.1-6-9.9-8.4z" ] []
        ]
