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
            , ( logo Strawberry 32, "logo Strawberry 32" )
            , ( logo Watermelon 32, "logo Watermelon 32" )
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

            Strawberry ->
                svgStrawberry size

            Watermelon ->
                svgWatermelon size


{-| Type of logos
-}
type Logo
    = Pencil
    | ExitFullscreen
    | Fullscreen
    | ElmMulticolor
    | ElmYellow
    | ElmWhite
    | Strawberry
    | Watermelon


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


svgWatermelon : Int -> Html.Html msg
svgWatermelon height =
    Svg.svg
        [ SA.viewBox "0 0 50.5 50.5"
        , SA.height <| toString height
        , SA.width <| toString <| floor <| toFloat height * 1
        ]
        [ Svg.path [ SA.fill "#88c057", SA.d "M18.4 24l1.4 4.5c.2 1.1-.6 2.2-1.7 2.6l-1.1.4-.3 1a4 4 0 0 1-2.7 2.7c-1.2.3-3.7-2.3-4.7-2.1L0 42.4A30 30 0 0 0 42.4 0l-24 24z" ] []
        , Svg.path [ SA.fill "#e22f37", SA.d "M37 5.3L18.5 24l1.4 4.5c.2 1.1-.6 2.2-1.7 2.6l-1.1.4-.3 1a4 4 0 0 1-2.7 2.7c-1.2.3-3.7-2.3-4.7-2.1l-4 4c8.8 9.5 22.4 8.7 31.5-.3S46.6 14 37 5.3z" ] []
        , Svg.circle [ SA.cx "4.5", SA.cy "17", SA.r "1.5", SA.fill "#231f20" ] []
        , Svg.circle [ SA.cx "16.5", SA.cy "39", SA.r "1.5", SA.fill "#231f20" ] []
        , Svg.circle [ SA.cx "26", SA.cy "25.6", SA.r "1.5", SA.fill "#231f20" ] []
        , Svg.circle [ SA.cx "30.9", SA.cy "20.7", SA.r "1.5", SA.fill "#231f20" ] []
        , Svg.circle [ SA.cx "28.1", SA.cy "37.6", SA.r "1.5", SA.fill "#231f20" ] []
        , Svg.circle [ SA.cx "33", SA.cy "32.7", SA.r "1.5", SA.fill "#231f20" ] []
        , Svg.circle [ SA.cx "38", SA.cy "27.7", SA.r "1.5", SA.fill "#231f20" ] []
        , Svg.circle [ SA.cx "35.9", SA.cy "15.7", SA.r "1.5", SA.fill "#231f20" ] []
        , Svg.circle [ SA.cx "22.4", SA.cy "36.2", SA.r "1.5", SA.fill "#231f20" ] []
        , Svg.circle [ SA.cx "27.5", SA.cy "31", SA.r "1.5", SA.fill "#231f20" ] []
        , Svg.circle [ SA.cx "32.5", SA.cy "26", SA.r "1.5", SA.fill "#231f20" ] []
        , Svg.circle [ SA.cx "7.5", SA.cy "27", SA.r "1.5", SA.fill "#231f20" ] []
        , Svg.circle [ SA.cx "13.5", SA.cy "19", SA.r "1.5", SA.fill "#231f20" ] []
        , Svg.circle [ SA.cx "37.3", SA.cy "21.4", SA.r "1.5", SA.fill "#231f20" ] []
        ]


svgStrawberry : Int -> Html.Html msg
svgStrawberry height =
    Svg.svg
        [ SA.viewBox "0 0 57 57"
        , SA.height <| toString height
        , SA.width <| toString <| floor <| toFloat height * 1
        ]
        [ Svg.path [ SA.fill "#659c35", SA.d "M29.8 9.4l-2.9.6L24 1.5 29 0z" ] []
        , Svg.path [ SA.fill "#88c057", SA.d "M36.1 8.5a8 8 0 0 0 2.4-3.6c-5.5-2-7.2.6-7.2.6 0-1-.9-1.5-2-1.6l.5 5.5-2.9.6-1.8-5.2c-.5.2-.8.5-.8.7 0 0-1.7-2.6-7.2-.6a7.9 7.9 0 0 0 2.4 3.7c-4.4.6-8.4 2-10.5 5.8 10.3 3 13.4-1.9 13.4-1.9.6 6.8 5.8 8.7 6.6 9 .8-.3 6-2.2 6.6-9 0 0 1.2 5 11.4 1.9-2.2-3.7-6.5-5.3-10.9-6z" ] []
        , Svg.path [ SA.fill "#e22f37", SA.d "M45.3 15v-.1c-8.7 2-9.7-2.4-9.7-2.4-.6 6.8-5.8 8.7-6.6 9-.8-.3-6-2.2-6.6-9 0 0-2.6 4-10.8 2.5C9.3 17.6 8 21.4 8 27c0 13 12.8 30 20.5 30C36.2 57 49 39.9 49 27c0-5.8-1.3-9.6-3.8-12h.1z" ] []
        , Svg.path [ SA.fill "#994530", SA.d "M17.3 20.7c-.1-.4-.7-.4-.8 0 0 0-1.5 5.3-1.5 5.8a2 2 0 0 0 1.9 1.9c.5 0 1-.2 1.4-.6.3-.3.5-.8.5-1.3s-1.5-5.8-1.5-5.8zm11.8 4c-.1-.4-.7-.4-.8 0 0 0-1.5 5.3-1.5 5.8a2 2 0 0 0 2 1.9c.4 0 1-.2 1.3-.6.3-.3.5-.8.5-1.3s-1.5-5.8-1.5-5.8zm11.2-4c-.1-.4-.7-.4-.8 0 0 0-1.5 5.3-1.5 5.8a2 2 0 0 0 1.9 1.9c.5 0 1-.2 1.4-.6.3-.3.5-.8.5-1.3s-1.5-5.8-1.5-5.8zm-18.2 13c-.1-.4-.7-.4-.8 0 0 0-1.5 5.3-1.5 5.8a2 2 0 0 0 2 2c.4 0 1-.3 1.3-.7.3-.3.5-.8.5-1.3s-1.5-5.8-1.5-5.8zm7 9c-.1-.4-.7-.4-.8 0 0 0-1.5 5.3-1.5 5.8a2 2 0 0 0 2 1.9c.4 0 1-.2 1.3-.6.3-.3.5-.8.5-1.3s-1.5-5.8-1.5-5.8zm7-9c-.1-.4-.7-.4-.8 0 0 0-1.5 5.3-1.5 5.8a2 2 0 0 0 2 1.9c.4 0 1-.2 1.3-.6.3-.3.5-.8.5-1.3s-1.5-5.8-1.5-5.8z" ] []
        ]
