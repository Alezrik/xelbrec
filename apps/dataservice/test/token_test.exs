defmodule TokenTest do
  use ExUnit.Case
  import Ecto.Changeset

  test "create valid object" do
    alias Dataservice.Schema.Permission
    alias Dataservice.Schema.PermissionGroup
    valid_permission_group =  %PermissionGroup{name: "MyPermissionGroup"}
    valid_permission = %Permission{permission_tag: "valid", "permission_group": valid_permission_group}
    valid_user = %Dataservice.Schema.User{name: "fdsa", password: "fdsafdsa", email: "fdsa@fdsa", permissions: [valid_permission]}
    alias Dataservice.Schema.Token
    invalid_changeset = %Token{} |> Token.changeset(%{token: "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjI0Nzk5IiwiZXhwIjoxNDg2NTkyOTQxLCJpYXQiOjE0ODQwMDA5NDEsImlzcyI6IlhlbGJyZWMiLCJqdGkiOiI3ZTQxYWU3MS0yMjdkLTQ3YjItYWU3MC00NzIwZmE4ZDRmNDMiLCJteVBlcm1pc3Npb25Hcm91cCI6WyJ0ZXN0X3RhZyIsInRlc3RfdGFnMiJdLCJwZW0iOnt9LCJzdWIiOiJVc2VyOjI0Nzk5IiwidHlwIjoiYXBpIn0.PtKQnqiy6UjKanx0Gi1RXxgXAahzNKrlrnMDsVTn2FcKLWjo1S5Oww2ULpEjYi3VA2yzTz5CABbq_7ZjivRL9g",
        expire: 1_486_592_941,
        issue: "Xelbrec",
        issue_time: 1_484_000_941,
        subject: "User:200"})

    valid_changeset = %Token{} |> Token.changeset(%{token: "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjI0Nzk5IiwiZXhwIjoxNDg2NTkyOTQxLCJpYXQiOjE0ODQwMDA5NDEsImlzcyI6IlhlbGJyZWMiLCJqdGkiOiI3ZTQxYWU3MS0yMjdkLTQ3YjItYWU3MC00NzIwZmE4ZDRmNDMiLCJteVBlcm1pc3Npb25Hcm91cCI6WyJ0ZXN0X3RhZyIsInRlc3RfdGFnMiJdLCJwZW0iOnt9LCJzdWIiOiJVc2VyOjI0Nzk5IiwidHlwIjoiYXBpIn0.PtKQnqiy6UjKanx0Gi1RXxgXAahzNKrlrnMDsVTn2FcKLWjo1S5Oww2ULpEjYi3VA2yzTz5CABbq_7ZjivRL9g",
                              expire: 1_486_592_941,
                              issue: "Xelbrec",
                              issue_time: 1_484_000_941,
                              subject: "User:300",
                              token_type: "api"}) |> put_assoc(:user, valid_user)

    assert valid_changeset.valid?
    refute invalid_changeset.valid?


  end
end
