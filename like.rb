require_relative 'questions_db.rb'

class Like
  attr_accessor :user_id, :question_id

  def self.find_by_id(question_id, user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id, question_id)
      SELECT
        *
      FROM
        likes
      WHERE
        user_id = ? AND question_id = ?
    SQL
    Like.new(data.first)
  end

  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        u.id, u.fname, u.lname
      FROM
        users AS u JOIN likes
          ON u.id = likes.user_id
      WHERE
        likes.question_id = ?
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*) AS num_likes
      FROM
        likes
      GROUP BY
        question_id = ?
    SQL
    data.first['num_likes']
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        q.id, q.title, q.body, q.author_id
      FROM
        questions AS q JOIN likes
          ON q.id = likes.question_id
      WHERE
        likes.user_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    return nil if options.nil?

    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
