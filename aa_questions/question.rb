require_relative 'questions_database.rb'

class Question
  attr_accessor :title, :body, :user_id
  attr_reader :id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    # p question
    return nil if question.empty?

    Question.new(question.first)
  end

  def self.find_by_user_id(id)
    user = User.find_by_id(id)
    raise "#{id} not found in DB" unless user

    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL

    question.map{ |q| Question.new(q) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO
        questions (title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end
end
