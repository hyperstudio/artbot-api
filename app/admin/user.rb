ActiveAdmin.register User do
  index do
    selectable_column
    id_column
    column :email
    column :last_sign_in_at
    column :created_at
    column :username
    column :authentication_token
    column :admin
    actions
  end
end
