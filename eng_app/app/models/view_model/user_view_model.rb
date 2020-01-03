module ViewModelBase

require 'bigdecimal'
  class UserViewModel
    def initialize(user)
      @user = user
    end
    #returns configurable setting name and values hash
    #return array of hash
    def configurable_settings
      [{item: "mode", value: @user.mode, description: "sentence sequence based on normal(nodemal mode), worst(worst mode)"}]
    end
    #top(num) return top X of sentence and score as Hash
    #key(sentence) value(score)
    def top(num)
      n = num - 1
      Hash[@user.scores.group(:sentence).sum(:val).sort_by{|_,v| -v}[0..n]]
    end

    #worst(num) return worst X of sentence and score as Hash
    #key(sentence) value(score)
    def worst(num)
      n = num - 1
      Hash[@user.scores.group(:sentence).sum(:val).sort_by{|_,v| +v}[0..n]]
    end

    def greater_than_one_score_sentence_count(type = Score)
      cond = {}
      cond = {type: type} if type != Score
      @user.scores.where(cond).group(:sentence).sum(:val).select{|s,val| val >= 1}.count
    end

    def all_sentence_count
      Sentence.count
    end

    def achievement_percent(type = Score)
      temp = (greater_than_one_score_sentence_count(type).to_f/all_sentence_count.to_f) * 100
      BigDecimal(temp.to_s).floor(2).to_f
    end
  end
end
