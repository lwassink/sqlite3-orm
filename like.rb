require_relative 'questions_db.rb'

class Like < Table
  attr_accessor :user_id, :question_id

  def self.table_name
    'likes'
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

  def self.most_liked_questions(n)
    return [] if n <= 0

    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        questions JOIN likes
          ON questions.id = likes.question_id
      GROUP BY questions.id
      ORDER BY COUNT(DISTINCT likes.user_id) DESC
      LIMIT ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    return nil if options.nil?

    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
