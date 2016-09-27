require_relative 'questions_db.rb'

class Table
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = #{id}
    SQL
    self.new(data.first)
  end

  def self.all
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    data.map { |datum| self.new(datum) }
  end

  def self.where(options)
    options = options.map do |key, val|
      "#{key} = " + (val.is_a?(String) ? "'#{val}'" : "#{val}")
    end.to_a.join(', ')
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{options}
    SQL
    data.map { |datum| self.new(datum) }
  end

  def save
    if @id
      QuestionsDatabase.instance.execute(<<-SQL)
        UPDATE
          #{self.class.table_name}
        SET
          #{update_variables}
        WHERE
          id = #{@id}
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL)
        INSERT INTO
          #{self.class.table_name} (#{insert_variables})
        VALUES
          (#{insert_values})
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

  def sanitized_variables
    vars = self.instance_variables
    vars.delete(:@id)
    vars.delete_if { |var| self.instance_variable_get(var).nil? }
    vars
  end

  def update_variables
    vars = sanitized_variables.map do |var|
      ["#{var.to_s[1..-1]} = ", self.instance_variable_get(var)]
    end

    vars.map do |var|
      var[0] + (var[1].is_a?(String) ? "'#{var[1]}'" : var[1].to_s)
    end.join(', ')
  end

  def insert_variables
    sanitized_variables.map { |var| "#{var.to_s[1..-1]}" }.join(", ")
  end

  def insert_values
    vars = sanitized_variables.map do |var|
      self.instance_variable_get(var)
    end

    vars.map do |var|
      var.is_a?(String) ? "'#{var}'" : var.to_s
    end.join(', ')
  end
end
