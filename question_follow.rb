require_relative 'questions_db.rb'

class QuestionFollow
  attr_accessor :question_id, :user_id

  def self.find_by_id(question_id, user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id, user_id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        question_id = ? AND user_id = ?
    SQL
    QuestionFollow.new(data.first)
  end

  def self.followers_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        users JOIN question_follows
          ON users.id = question_follows.user_id
      WHERE
        question_follows.question_id = ?
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        questions JOIN question_follows
          ON questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n)
    return [] if n <= 0
    
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        questions JOIN question_follows
          ON questions.id = question_follows.question_id
      GROUP BY question_follows.question_id
      ORDER BY COUNT(DISTINCT question_follows.user_id) DESC
      LIMIT ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    return nil if options.nil?

    @question_id = options['question_id']
    @user_id = options['user_id']
  end
end
