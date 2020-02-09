module ViewModelBase

require 'bigdecimal'

  class UserViewModel
    def initialize(user)
      @user = user
    end
    #returns configurable setting name and values hash
    #return array of hash
    def configurable_settings
      [{item: "mode", value: @user.mode, description: "sentence sequence based on normal(nodemal mode), top(top mode), worst(worst mode)"}]
    end
    #top(num) return top X of sentence and score as Array of Array 
    #Element of Array is [sentence(object), score(int)]
    def top(num = nil)
      temp = @user.scores.group(:sentence).sum(:val).sort_by{|_,v| -v}
      filter_by_num(temp, num)
    end

    #normal(num) return normal(without considering score, only order of number) X of sentence and score as Array of Array 
    #Element of Array is [sentence(object), score(int)]
    def normal(num = nil)
      temp = @user.scores.group(:sentence).sum(:val).sort_by{|sentence,val| sentence.no.to_i}
      filter_by_num(temp, num)
    end

    #worst(num) return top X of sentence and score as Array of Array 
    #Element of Array is [sentence(object), score(int)]
    def worst(num = nil)
      temp = @user.scores.group(:sentence).sum(:val).sort_by{|_,v| +v}
      filter_by_num(temp, num)
    end

    #return sentences as Array of Array based on user's mode
    def sentences
      case @user.mode
      when UserActionMode::NORMAL
        normal
      when UserActionMode::TOP
        top
      when UserActionMode::WORST
        worst
      else 
        raise "ERROR: no such pattern"
      end
    end

    def sentences_with_pagenate(page, per)
      Kaminari.paginate_array(sentences).page(page).per(per)
    end

    def prev_sentence(_sentence)
      sent = sentences
      max = sent.count
      i = sent.index{|sentence, val| sentence.no == _sentence.no}
      if i - 1 < 0 
        sent[max - 1]
      else
        sent[i - 1]
      end
    end

    def next_sentence(_sentence)
      sent = sentences
      max = sent.count
      i = sent.index{|sentence, val| sentence.no == _sentence.no}
      if i + 1 < max
        sent[i + 1]
      else
        sent[0]
      end
    end

    def all_try_count
      @user.scores.group(:sentence).count.select{|sentence, count| count > 1}.count
    end

    def all_try_percent
      temp = (all_try_count.to_f/all_sentence_count.to_f) * 100
      BigDecimal(temp.to_s).floor(2).to_f
    end

    def greater_than_one_score_sentence_count(type = Score)
      cond = {}
      cond = {type: type} if type != Score

      if type == Score
        res = 0
        for t in [ScoreEngNotWritten, ScoreEngWritten]
          cond = {type: t}
          res += @user.scores.where(cond).group(:sentence).sum(:val).select{|s,val| val >= 1}.count
        end
        return res
      end
      @user.scores.where(cond).group(:sentence).sum(:val).select{|s,val| val >= 1}.count
    end

    def all_sentence_count
      Sentence.count
    end

    def achievement_percent(type = Score)
      temp = (greater_than_one_score_sentence_count(type).to_f/all_sentence_count.to_f) * 100
      BigDecimal(temp.to_s).floor(2).to_f
    end

    protected

    def filter_by_num(ary, num = nil)
      if num
        n = num - 1
        return ary[0..n]
      else 
        return ary 
      end
    end
  end
end
