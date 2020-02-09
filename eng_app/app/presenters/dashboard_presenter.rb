class DashboardPresenter
  def initialize(user)
    @vm = user.view_model
  end

  def all_try_index_table
    temp = ""
    temp += <<-EOS
      <h2>all try index</h2>
      <table>
        <thead>
          <tr>
            <th>all try count</th>
            <th>all sentences</th>
            <th>achievement percent</th>
            <th colspan="3"></th>
          </tr>
        </thead>
    
        <tbody>
            <tr>
              <td>#{@vm.all_try_count}</td>
              <td>#{@vm.all_sentence_count}</td>
              <td>#{@vm.all_try_percent}</td>
            </tr>
        </tbody>
      </table>
    EOS
    temp.html_safe
  end


  def achievement_index_table
    temp = ""
    for type in [Score, ScoreEngNotWritten, ScoreEngWritten] do 
      temp += <<-EOS
      <h2>achievement index of #{type}</h2>
      <table>
        <thead>
          <tr>
            <th>greater_than_one_score_sentence_count</th>
            <th>all sentences</th>
            <th>achievement percent</th>
            <th colspan="3"></th>
          </tr>
        </thead>
    
        <tbody>
            <tr>
              <td>#{@vm.greater_than_one_score_sentence_count(type)}</td>
              <td>#{@vm.all_sentence_count}</td>
              <td>#{@vm.achievement_percent(type)}</td>
            </tr>
        </tbody>
      </table>
      EOS
    end
    temp.html_safe
  end

  def top_x_good_score_sentences_table(n)
    list_sentence("Top #{n} good score Sentences", @vm.top(n))
  end

  def top_x_worst_score_sentences_table(n)
    list_sentence("Worst #{n} bad score Sentences", @vm.worst(n))
  end
private
  def list_sentence(title, list)
    content = ""
    list.each do |sentence, score|
      content += <<-EOS
        <tr>
          <td> #{sentence.no} </td>
          <td> #{sentence.jp} </td>
          <td> #{score} </td>
          <td><a href="/sentences/#{sentence.id}">Show</a></td>
        </tr>
      EOS
    end

    temp = <<-EOS
    <h2>#{title}</h2>
    <table>
      <thead>
        <tr>
          <th>No</th>
          <th>Jp</th>
          <th>score</th>
          <th colspan="3"></th>
        </tr>
      </thead>
    
      <tbody>
         #{content}
      </tbody>
    </table>
    EOS
    temp.html_safe
  end
end
