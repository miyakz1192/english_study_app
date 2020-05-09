
class WordMeaningPresenter

  def initialize(data)
    temp = "" 

    if data.blank?
      temp << td("data collecting now", "data collecting now", "http://google.com")
    else 
      data.each do |wm|
        temp << td(wm["en"], wm["note"], wm["url"])
      end
    end

    @html_data = table(temp)
  end

  #data: WordMeaningService.get result
  def html
    @html_data
  end

protected
  def td(word, meaning, link)
    "<tr class=\"wmtr\">
        <td class=\"wmtd\"><a href=\"#{link}\" class=\"wma\">#{word}</a></td>
        <td class=\"wmtd\">#{meaning}</td>
     </tr>
    "
  end

  def table(data)
    "<table border=\"5\" bordercolor=\"bule\" class=\"wmtable\">
       <tr class=\"wmtr\">
         <th class=\"wmth\">word</th>
         <th class=\"wmth\">meaning</th>
       </tr>
       #{data}
     </table>
    "
  end
end
