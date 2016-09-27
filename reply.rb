require_relative 'questions_db.rb'

class Reply < Table
  attr_accessor :id, :subject_question_id, :author_id, :body, :parent_reply_id

  def self.table_name
    'replies'
  end

  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        author_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        subject_question_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end

  def initialize(options)
    return nil if options.nil?

    @id = options['id']
    @subject_question_id = options['subject_question_id']
    @author_id = options['author_id']
    @body = options['body']
    @parent_reply_id = options['parent_reply_id']
  end

  def author
    User.find_by_id(@author_id)
  end

  def questions
    Question.find_by_id(@subject_question_id)
  end

  def parent_reply
    self.class.find_by_id(@parent_reply_id)
  end

  def child_replies
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end
end
