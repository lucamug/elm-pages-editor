module Element.Hack exposing (..)

import Element
import Html
import Html.Attributes
import Window


type alias Device =
    { width : Int
    , height : Int
    , phone : Bool
    , tablet : Bool
    , desktop : Bool
    , bigDesktop : Bool
    , portrait : Bool
    }


classifyDevice : Window.Size -> Device
classifyDevice { width, height } =
    { width = width
    , height = height
    , phone = width <= 600
    , tablet = width > 600 && width <= 1200
    , desktop = width > 1200 && width <= 1800
    , bigDesktop = width > 1800
    , portrait = width < height
    }


styleElement : String -> Element.Element msg
styleElement text =
    Element.html (Html.node "style" [] [ Html.text text ])


class : String -> Element.Attribute msg
class name =
    Element.attribute (Html.Attributes.class name)


style : ( String, String ) -> Element.Attribute msg
style style =
    Element.attribute (Html.Attributes.style [ style ])


value : String -> Element.Attribute msg
value value =
    Element.attribute (Html.Attributes.value value)
