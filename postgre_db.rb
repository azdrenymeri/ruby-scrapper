require 'pg'

connection = PG.connect(dbname: 'sample_db', user:'ruby_client',password:'ruby')


connection.exec("SELECT id, user_name, user_password
    FROM public.users_table;") do |result|

        result.each do |row|

            puts row.values_at('user_name','user_password')
            puts "-----------------------------------------"
        end

end
