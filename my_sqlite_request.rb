require 'csv'

class MySqliteRequest
    attr_accessor :headers

    def initialize()
        @headers = nil # contains the headers of the csv file
        @table_name = nil # contains the path to the table
        @table = nil # contains the parsed CSV file from the CSV gem
        @select = []
        @where_column = ''
        @where_criteria = ''
        @join_column_a = ''
        @db_b = ''
        @join_column_b = ''
        @select_results = []
        @values = []
        @query_type = nil
        @set_data = []
        @set_column = []
        @where_results = []
        @order = ""
        @order_column = ""
        @where_flag = false
        @columns = nil
    end

    def query_checker(query)
        raise "Too many query types" unless @query_type == query
    end

    def table_builder(path) # intakes a csv file, outputs an array of hashes corresponding to the row of data. outputs the headers as well 
        if !path.end_with? ".csv" 
            path << ".csv"
        end
        table = []
        headers = nil
        CSV.foreach(path, headers: true ,header_converters: :symbol) do |hash| # iterate through rows of the CSV
            hash.each do |key, val| # iterate through the hash of the row
                if Integer(val, exception:false).nil? # if the value can be cast as an integer, do so
                    next
                end
                hash[key] = val.to_i # cast it to integer
            end
            headers ||= hash.headers
            table << hash.to_h # table is an array, append the hash to it as a hash
        end
        return [table,headers]
    end

    def from(table_name) # loads a table to @table_name, will append .csv if necessary
        if !table_name.end_with? ".csv"
            table_name << ".csv"
        end
        @table_name = table_name
        @table, @headers = table_builder(@table_name)
        self
    end

    def select(*columns) # gets the columns of interest for the run_select column -> is run last after being narrowed by the run_where function
        @columns = columns
        if columns.class == Array

            columns = columns.flatten(1)
        end
        @select = columns
        if columns[0] == "*"
            @select = @headers.map{ |x| x.to_s}
        end
        @query_type ||= "select"
        query_checker("select")
        self
    end

    def run_where() # pushes the results of the "where" query to @where_results, which is a narrowed data set from our original table, used for the select command
        @table.compact!
        @table.each do |hash|
            if hash == nil
                next
            end
            if hash[@where_column.to_sym] == @where_criteria
                @where_results.push(hash)
            end
        end
        @where_flag = true
    end

    def where(column, criteria) # gets the column and criteria for the run_where function
        @where_column = column
        @where_criteria = criteria
        self
    end

    def order(column_name,order) # order = string, column name = string
        @order = order
        @order_column = column_name
        self
    end

    def run_order()
        @select_results = @select_results.sort_by{|hsh| hsh[@order_column.to_sym]}
        if @order.downcase == "desc"
            @select_results.reverse!
        end
    end

    def join(column_on_a, filename_db_b, columname_on_db_b) # gets the filename to be joined, as well as the columns to join
        @join_column_a = column_on_a
        @db_b = filename_db_b
        @join_column_b = columname_on_db_b
        self
    end

    def run_join() # joins the two csv tables together where entry_from_table_a[column_to_join_a] ==  entry_from_table_b[column_to_join_b]
                   # returns a new table called newtable with the merged rows
        csv1, headers1 = table_builder(@table_name)
        csv2, headers2 = table_builder(@db_b) # gets table 2 provided by the join function

        joined_table = []
        @headers = headers1 + headers2

            csv1.each_with_index do |hash, i|
                csv2.each_with_index do |hashb, j|
                    if csv1[i][@join_column_a.to_sym] == csv2[j][@join_column_b.to_sym]
                        joined_table[i] = csv1[i].merge(csv2[j])
                    end

                end
            end
        if @columns[0] == "*"
            @select = @headers.map{ |x| x.to_s}
        end
        
        @table = joined_table
        if @where_flag
            run_where
        end
        self
    end

    def insert(table_name)
        # insert function should:
        # build the table using table_builder, which initialized @table and @headers
        @table_name = table_name
        @table, @headers = table_builder(@table_name)
        @query_type ||= "insert"
        query_checker("insert")
        puts "Record Inserted!"
        self
    end

    def values(data)
        # validate the data
        raise "keys from data don't match headers" unless data.size == @headers.size and (data.keys - @headers).empty?
        @table.push(data)
        self
    end

    def update(table_name)
        @table_name = table_name
        @table, @headers = table_builder(table_name)
        @query_type ||= "update"
        query_checker("update")
        puts "Record Updated"
        self
    end

    def set(data)
        @set_data = data
        self
    end
        
    def run()
        case @query_type
        when "select"
            if @db_b != ""
                run_join
            end
            if @where_column != '' 
                #puts "run where executed"
                run_where
            end
            run_select
        when "insert"
            update_table
        when "update"
            run_update
        when "delete"
            run_delete
        end
        reset()
    end

    def reset()
        @headers = nil # contains the headers of the csv file
        @table_name = nil # contains the path to the table
        @table = nil # contains the parsed CSV file from the CSV gem
        @select = []
        @where_column = ''
        @where_criteria = ''
        @join_column_a = ''
        @db_b = ''
        @join_column_b = ''
        @select_results = []
        @values = []
        @query_type = nil
        @set_data = []
        @set_column = []
        @where_results = []
        @order = ""
        @order_column = ""
        @where_flag = false
        @columns = nil
    end


    def run_select()
        if @where_results.size != 0 && @where_flag # if the run_where command was run, select from only those narrowed results
            @table = @where_results
        end
        if @where_results.size == 0 && @where_flag
            puts "No results found! Check your where statement"
            return
        end


        @table.each_with_index do |hash| # iterate over hashes of the table
            if hash == nil
                next
            end
            newhash = {} # create a newhash to add to @select_results
            @select.each do |column| # passes in every header as an individual string
                newhash[column.to_sym] = hash[column.to_sym]
            end
            @select_results.push(newhash)
        end

        if @order
            run_order
        end

        @select_results = @select_results.uniq

        @select_results.each_with_index do |hash, index| # format the hashes for output
            output = ''
            hash.each do |key, value|
                output += value.to_s + "|"
            end
            output.chop!
            print output
            puts
        end

    end

    def update_table()
        temp_header_array = []
        @headers.each_with_index do |element, index| # push the headers to temp_header_array to append it to the csv
            temp_header_array.push(@headers[index].to_s)
        end
        CSV.open(@table_name, "w+") do |csv|
            csv << temp_header_array
                @table.each do |hash|
                csv << hash.values
            end
        end
    end

    def run_update()
        @table.each do |hash| # iterates over all the hashes in the array of hashes
            if hash[@where_column.to_sym] == @where_criteria # if the where criteria is met, then loop over all the key values in @set_data that you want to replace
                @set_data.each do |key, value| # loop over every kv that we need to replace
                    hash[key] = value
                end
            end
        end

       update_table()  
    end

    def run_delete()
        # table is an array of hashes table[i] == hash at i index
        @table.each do |element| # element is a hash
            if (element[@where_column.to_sym] == @where_criteria)
                # delete hash row
                @table.delete(element)
                puts "Record Deleted!"
            end
        end
        update_table()
    end

    def delete()
        @query_type = "delete"
        query_checker("delete")
        self
    end
end

