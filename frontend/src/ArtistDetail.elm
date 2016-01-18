module ArtistDetail (Model, Action (..), init, view, update) where


import ServerApi exposing (Artist, ArtistRequest, getArtist, updateArtist, createArtist)
import Routes
import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, on, targetValue)
import Debug


type alias Model =
  { id : Maybe Int
  , name : String
  }


type Action =
    NoOp
  | GetArtist (Int)
  | ShowArtist (Maybe Artist)
  | SetArtistName (String)
  | SaveArtist
  | HandleSaved (Maybe Artist)


init : Model
init =
   Model Nothing ""


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of

    NoOp ->
      (model, Effects.none)

    GetArtist id ->
      (model, getArtist id ShowArtist)

    ShowArtist maybeArtist ->
      case maybeArtist of
        Just artist ->
          ( { model | id = Just artist.id
                    , name = artist.name}
          , Effects.none
          )
        -- TODO: This could be an error if returned from api !
        Nothing ->
          ( { model | id = Nothing
                    , name = ""}
          , Effects.none
          )

    SaveArtist ->
      case model.id of
        Just id ->
          (model, updateArtist (Artist id model.name) HandleSaved)
        Nothing ->
          (model, createArtist {name = model.name} HandleSaved)

    HandleSaved maybeArtist ->
      case maybeArtist of
        Just artist ->
          ({ model | id = Just artist.id
                   , name = artist.name }
            , Effects.map (\_ -> NoOp) (Routes.redirect Routes.ArtistListingPage)
          )

        Nothing ->
          Debug.crash "Save failed... we're not handling it..."


    SetArtistName txt ->
      ( { model | name = txt }
      , Effects.none
      )


pageTitle : Model -> String
pageTitle model =
  case model.id of
    Just x -> "Edit artist"
    Nothing -> "New artist"



view : Signal.Address Action -> Model -> Html
view address model =
  div [] [
      h1 [] [text <| pageTitle model]
    , Html.form [class "form-horizontal"] [
        div [class "form-group"] [
            label [class "col-sm-2 control-label"] [text "Name"]
          , div [class "col-sm-10"] [
              input [
                  class "form-control"
                , value model.name
                , on "input" targetValue (\str -> Signal.message address (SetArtistName str))
              ] []
            ]
        ]
        , div [class "form-group"] [
            div [class "col-sm-offset-2 col-sm-10"] [
              button [
                  class "btn btn-default"
                , type' "button"
                , onClick address SaveArtist
              ]
              [text "Save"]
            ]
        ]
    ]
  ]


