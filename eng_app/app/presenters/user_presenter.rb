
class UserPresenter
  def initialize(user)
    @user = user
  end

  def user_setting_table_html
    settings = ""
    user.view_model.configurable_settings.each do |i|
      settings += "<td>#{i[:item]}</td>"
      settings += "<td>#{i[:value]}</td>"
      settings += "<td>#{i[:description]}</td>"
    end

    res = <<-EOS
      <table>
        <thead>
          <tr>
            <th>item</th>
            <th>value</th>
            <th>description</th>
            <th colspan="3"></th>
          </tr>
        </thead>
    
        <tbody>
            <tr>
              #{settings}
            </tr>
        </tbody>
      </table>
    EOS
    res.html_safe
  end

  private 

  def user
    @user
  end
end
