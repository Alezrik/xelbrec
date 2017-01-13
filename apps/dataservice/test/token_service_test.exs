defmodule TokenServiceTest do
  use ExUnit.Case
  doctest Dataservice
      alias Dataservice.Schema.PermissionGroup
      alias Dataservice.Schema.Permission
      alias Dataservice.Schema.User
      alias Dataservice.Repo
      alias Dataservice.Service.UserService
      alias Dataservice.Service.TokenService
      alias Dataservice.Schema.Token

  test "crud tests" do

        Permission
        |> Repo.delete_all

        PermissionGroup
        |> Repo.delete_all

        Token
        |> Repo.delete_all
        User
        |> Repo.delete_all
        user = %User{name: "john", password: "fdsafdsa", email: "fdsa@fdsa"}
        {:ok, inserted_user} = GenServer.call(UserService, {:insert, user})
        {:ok, valid_user} = GenServer.call(UserService, {:get, inserted_user.id})
        token = %Token{token: "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjI0Nzk5IiwiZXhwIjoxNDg2NTkyOTQxLCJpYXQiOjE0ODQwMDA5NDEsImlzcyI6IlhlbGJyZWMiLCJqdGkiOiI3ZTQxYWU3MS0yMjdkLTQ3YjItYWU3MC00NzIwZmE4ZDRmNDMiLCJteVBlcm1pc3Npb25Hcm91cCI6WyJ0ZXN0X3RhZyIsInRlc3RfdGFnMiJdLCJwZW0iOnt9LCJzdWIiOiJVc2VyOjI0Nzk5IiwidHlwIjoiYXBpIn0.PtKQnqiy6UjKanx0Gi1RXxgXAahzNKrlrnMDsVTn2FcKLWjo1S5Oww2ULpEjYi3VA2yzTz5CABbq_7ZjivRL9g",
                                      expire: 1_486_592_941,
                                      issue: "Xelbrec",
                                      issue_time: 1_484_000_941,
                                      subject: "User:300",
                                      token_type: "api", user: valid_user}

         {:ok, _insert_token} = GenServer.call(TokenService, {:insert, token})

         {:ok, [gettoken]} = GenServer.call(TokenService, {:get, :all})

         {:ok, checktoken} = GenServer.call(TokenService, {:get, gettoken.id})

         assert checktoken.id == gettoken.id

         {:ok, _byusertoken} = GenServer.call(TokenService, {:get_by_user, valid_user})

         user2 = %User{name: "johnny", password: "fdsafdsa", email: "fdsaaaaa@fdsa"}
         {:ok, inserted_user2} = GenServer.call(UserService, {:insert, user2})
         {:ok, valid_user2} = GenServer.call(UserService, {:get, inserted_user2.id})

         token2 = %Token{token: "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjI0Nzk5IiwiZXhwIjoxNDg2NTkyOTQxLCJpYXQiOjE0ODQwMDA5NDEsImlzcyI6IlhlbGJyZWMiLCJqdGkiOiI3ZTQxYWU3MS0yMjdkLTQ3YjItYWU3MC00NzIwZmE4ZDRmNDMiLCJteVBlcm1pc3Npb25Hcm91cCI6WyJ0ZXN0X3RhZyIsInRlc3RfdGFnMiJdLCJwZW0iOnt9LCJzdWIiOiJVc2VyOjI0Nzk5IiwidHlwIjoiYXBpIn0.PtKQnqiy6UjKanx0Gi1RXxgXAahzNKrlrnMDsVTn2FcKLWjo1S5Oww2ULpEjYi3VA2yzTz5CABbq_7ZjivRL9g",
                                               expire: 1_486_592_941,
                                               issue: "Xelbrec",
                                               issue_time: 1_484_000_941,
                                               subject: "User:400",
                                               token_type: "api", user: valid_user2}

         {:ok, insert_token2} = GenServer.call(TokenService, {:insert, token2})
         {:ok, _checktoken2} = GenServer.call(TokenService, {:get, insert_token2.id})




         {:ok, [byusertoken2]} = GenServer.call(TokenService, {:get_by_user, valid_user})
         assert byusertoken2.subject == "User:300"

         {:ok, [byusertoken3]} = GenServer.call(TokenService, {:get_by_user, valid_user2})

         assert byusertoken3.subject == "User:400"

         {:ok, _deleted_item} = GenServer.call(TokenService, {:delete, byusertoken2.id})
         {:ok, _deleted_item} = GenServer.call(TokenService, {:delete, byusertoken3.id})

         Permission
         |> Repo.delete_all

         PermissionGroup
         |> Repo.delete_all

         Token
         |> Repo.delete_all
         User
         |> Repo.delete_all




  end
end
