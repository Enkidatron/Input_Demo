module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onCheck)
import Html.App as App
import String


main : Program Never
main =
    App.beginnerProgram
        { model = model
        , view = view
        , update = update
        }



-- MODEL


type Input a
    = NoInput
    | InvalidInput String String
    | ValidInput String a


type Feature
    = Simple String
    | Complex String Int


type alias Person =
    { name : String
    , age : Int
    , feature : Feature
    }


type alias InputBlock =
    { nameInput : Input String
    , ageInput : Input Int
    , useSimple : Bool
    , simpleInput : Input String
    , complexInput1 : Input String
    , complexInput2 : Input Int
    }


blankInputBlock : InputBlock
blankInputBlock =
    InputBlock NoInput NoInput True NoInput NoInput NoInput


type alias Model =
    { people : List Person
    , input : InputBlock
    }


model : Model
model =
    Model [] blankInputBlock


type Msg
    = SetInputName String
    | SetInputAge String
    | SetUseSimple Bool
    | SetInputSimple String
    | SetInputComplex1 String
    | SetInputComplex2 String
    | AddPerson



-- UPDATE


update : Msg -> Model -> Model
update msg ({ input } as model) =
    case msg of
        SetInputName text ->
            { model | input = { input | nameInput = (validateInput text isNotBlank) } }

        SetInputAge text ->
            { model | input = { input | ageInput = (validateInput text isNotNegative) } }

        SetUseSimple bool ->
            { model | input = { input | useSimple = bool } }

        SetInputSimple text ->
            { model | input = { input | simpleInput = (validateInput text isNotBlank) } }

        SetInputComplex1 text ->
            { model | input = { input | complexInput1 = (validateInput text isNotBlank) } }

        SetInputComplex2 text ->
            { model | input = { input | complexInput2 = (validateInput text isNotNegative) } }

        AddPerson ->
            let
                maybeFeature =
                    case ( model.input.useSimple, model.input.simpleInput, model.input.complexInput1, model.input.complexInput2 ) of
                        ( True, ValidInput _ simple, _, _ ) ->
                            Just <| Simple simple

                        ( False, _, ValidInput _ complex1, ValidInput _ complex2 ) ->
                            Just <| Complex complex1 complex2

                        _ ->
                            Nothing

                ( newPerson, newInput ) =
                    case ( model.input.nameInput, model.input.ageInput, maybeFeature ) of
                        ( ValidInput _ name, ValidInput _ age, Just feature ) ->
                            ( [ Person name age feature ], blankInputBlock )

                        _ ->
                            ( [], input )
            in
                { model
                    | people = model.people ++ newPerson
                    , input = newInput
                }



-- UPDATE HELPERS


validateInput : String -> (String -> Result String a) -> Input a
validateInput raw validator =
    case validator raw of
        Ok value ->
            ValidInput raw value

        Err errormessage ->
            InvalidInput raw errormessage


isNotBlank : String -> Result String String
isNotBlank text =
    if not <| String.isEmpty text then
        Ok text
    else
        Err "Cannot be blank"


isNotNegative : String -> Result String Int
isNotNegative text =
    let
        checkInt x =
            if x >= 0 then
                Ok x
            else
                Err "Number cannot be negative"
    in
        String.toInt text `Result.andThen` checkInt



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewInput "Name" "text" model.input.nameInput SetInputName
        , viewInput "Age" "number" model.input.ageInput SetInputAge
        , viewFeatureBlock model.input
        , button [ onClick AddPerson, disabled <| shouldDisableButton model.input ] [ text "Add Person" ]
        , div [] (List.map viewPerson model.people)
        ]


viewInput : String -> String -> Input a -> (String -> Msg) -> Html Msg
viewInput label inputtype input' msg =
    let
        ( str, errorText ) =
            case input' of
                NoInput ->
                    ( "", "" )

                InvalidInput rawText errorMessage ->
                    ( rawText, errorMessage )

                ValidInput rawText _ ->
                    ( rawText, "" )
    in
        p []
            [ text label
            , input [ type' inputtype, onInput msg, placeholder label, value str ] []
            , text errorText
            ]


viewFeatureBlock : InputBlock -> Html Msg
viewFeatureBlock inputBlock =
    let
        inputs =
            if inputBlock.useSimple then
                [ viewInput "Simple" "text" inputBlock.simpleInput SetInputSimple ]
            else
                [ viewInput "Complex1" "text" inputBlock.complexInput1 SetInputComplex1
                , viewInput "Complex2" "number" inputBlock.complexInput2 SetInputComplex2
                ]
    in
        p []
            ([ input [ type' "checkbox", onCheck SetUseSimple, checked inputBlock.useSimple ] []
             ]
                ++ inputs
            )


viewPerson : Person -> Html Msg
viewPerson person =
    div []
        [ text "Name: "
        , text person.name
        , text " Age: "
        , text <| toString person.age
        , text " Feature: "
        , text <| toString person.feature
        ]


shouldDisableButton : InputBlock -> Bool
shouldDisableButton { nameInput, ageInput, useSimple, simpleInput, complexInput1, complexInput2 } =
    case ( nameInput, ageInput, useSimple, simpleInput, complexInput1, complexInput2 ) of
        ( ValidInput _ _, ValidInput _ _, True, ValidInput _ _, _, _ ) ->
            False

        ( ValidInput _ _, ValidInput _ _, False, _, ValidInput _ _, ValidInput _ _ ) ->
            False

        _ ->
            True
