require_relative 'questions_database'
require_relative 'question'
require_relative 'user'

class Reply
  attr_accessor :user_id, :question_id, :parent_reply_id, :body
  attr_reader :id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    return nil if reply.empty?

    Reply.new(reply.first)
  end

  def self.find_by_user_id(id)
    user = User.find_by_id(id)
    raise "#{id} not found in DB" unless user

    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL

    reply.map{ |r| Reply.new(r) }
  end

  def self.find_by_question_id(id)
    question = Question.find_by_id(id)
    raise "#{id} not found in DB" unless question

    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    reply.map{ |r| Reply.new(r) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @body = options['body']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id, @parent_reply_id, @body)
      INSERT INTO
        replies (user_id, question_id, parent_reply_id, body)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id,  @parent_reply_id, @body, @id)
      UPDATE
        replies
      SET
        user_id = ?, question_id = ?, parent_reply_id = ?, body = ?
      WHERE
        id = ?
    SQL
  end

  def user
    user = QuestionsDatabase.instance.execute(<<-SQL, self.user_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    raise "#{id} not found in DB" unless user
    user.map{ |u| User.new(u) }
  end

  def question
    question = QuestionsDatabase.instance.execute(<<-SQL, self.question_id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    raise "#{self.id} not found in DB" unless question
    question.map{ |q| Question.new(q) }
  end

  def parent_reply
    parent = Reply.find_by_id(self.parent_reply_id)
    return nil unless parent
  end

  def child_replies
    child =  QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = ?
    SQL
    return nil if child.length <= 0
    child.map{ |c| Reply.new(c) }
  end

end
