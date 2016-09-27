require_relative 'questions_db.rb'
require_relative 'table'

class User < Table
  attr_accessor :id, :fname, :lname

  def self.table_name
    'users'
  end

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    data.map { |datum| User.new(datum) }
  end

  def initialize(options)
    return nil if options.nil?

    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    Like.liked_questions_for_user_id(@id)
  end

  def average_karma
    data = QuestionsDatabase.instance.execute(<<-SQL, @id, @id)
      SELECT
        tc.total_questions / CAST(tl.total_likes AS FLOAT) AS karma
      FROM
        (
          SELECT
            COUNT(*) AS total_questions
          FROM
            questions
          WHERE
            questions.author_id = ?) AS tc JOIN
        (
          SELECT
            COUNT(*) AS total_likes
          FROM
            likes JOIN questions
            ON likes.question_id = questions.id
          WHERE
            questions.id = ?) AS tl
    SQL
    data.first['karma'] || 0
  end
end
