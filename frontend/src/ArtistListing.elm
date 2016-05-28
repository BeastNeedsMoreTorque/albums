module ArtistListing exposing (Model, Msg, init, view, update, mountCmd)

import ServerApi exposing (..)
import Routes
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Http


type alias Model =
    { artists : List Artist
    , errors : List String
    }


type Msg
    = Show
    | HandleArtistsRetrieved (List Artist)
    | FetchArtistsFailed Http.Error
    | DeleteArtist Int
    | HandleArtistDeleted
    | DeleteFailed


init : Model
init =
    Model [] []


mountCmd : Cmd Msg
mountCmd =
    ServerApi.getArtists FetchArtistsFailed HandleArtistsRetrieved


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        Show ->
            ( model, mountCmd )

        HandleArtistsRetrieved artists ->
            ( { model | artists = artists }
            , Cmd.none
            )

        -- Handle error
        FetchArtistsFailed err ->
            ( model, Cmd.none )

        DeleteArtist id ->
            ( model, deleteArtist id DeleteFailed HandleArtistDeleted )

        HandleArtistDeleted ->
            update Show model

        -- Show generic error
        DeleteFailed ->
            ( model, Cmd.none )



------ VIEW ------


artistRow : Artist -> Html Msg
artistRow artist =
    tr []
        [ td [] [ text artist.name ]
        , td []
            [ Routes.linkTo (Routes.ArtistDetailPage artist.id)
                [ class "btn btn-sm btn-default" ]
                [ text "Edit" ]
            ]
        , td []
            [ button
                [ class "btn btn-sm btn-danger"
                , onClick <| DeleteArtist (.id artist)
                ]
                [ text "Delete!" ]
            ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Artists" ]
        , Routes.linkTo Routes.NewArtistPage
            [ class "pull-right btn btn-default" ]
            [ text "New Artist" ]
        , table [ class "table table-striped" ]
            [ thead []
                [ tr []
                    [ th [] [ text "Name" ]
                    , th [] []
                    , th [] []
                    ]
                ]
            , tbody [] (List.map artistRow model.artists)
            ]
        ]
