time = Time.new
puts "MySQLite version 0.1 #{time.strftime("%Y/%d/%m")}"
require_relative "my_sqlite_request.rb"

class CLI_Interface
    @@csvr = MySqliteRequest.new

    def initialize()
        @cli_input = "" # string
        @input = nil    # array
        @table = ''
    end
    
    def get_input()
        # get user input
        @cli_input = gets.chomp

        if @cli_input == "exit" 
            puts "exiting program"
            return
        end

        # parse user input
        @input = @cli_input.split
    
        case @input[0]
        when "SELECT" # DONE 
            if (@cli_input.include? "ORDER BY")
                cli_order()
            end
            if (@cli_input.include? "WHERE")
                cli_where()
            end
            if (@cli_input.include? "JOIN")
                cli_join()
            end
            cli_select()
        when "INSERT"
            cli_insert()
        when "UPDATE"
            cli_where()
            cli_update()
        when "DELETE"
            cli_where()
            cli_delete()
        else
            puts "Invalid input."
        end
    end

    def cli_select()
        # SELECT name, weight FROM data.csv JOIN data_to_join ON name = player
        # SELECT name, weight FROM data.csv
        # SELECT name, weight FROM data.csv ORDER BY name ASC
        column = @cli_input.split("FROM").first.tr("SELECT ", "").split(",")
        @table = @cli_input.split("FROM").last.tr!(" ", "")
    
        # validate query
        if (!@cli_input.include? "FROM" || !table || (column.include? " ") )
            raise "Invalid Syntax \n\tSYNTAX: SELECT column1, column2 FROM table"
            get_input()
        end
        # execute query
        #puts "@@csvr.select(#{column}).from(#{table}).run"
        @@csvr.from(@table).select(column).run
        get_input()
    end

    def cli_where() #                     |
        # UPDATE data.csv SET college = "University of California, Santa Cruz", name = "Connor" WHERE name = "Alex Abrines"
        @cli_input, where = @cli_input.split(" WHERE ") # splits the string in between WHERE, the first part becomes @cli_input, second part becomes where
        column, criteria = where.split(" = ")
        if Integer(criteria, exception:false) # if the value can be cast as an integer, do so
            criteria = criteria.to_i
        else
            # if it is a string, trim the quotes
            criteria.tr!("';", "")
            criteria.tr!('"', "")
        end
        @@csvr.where(column,criteria)
    end
    
    def cli_insert()
        # INSERT INTO data.csv VALUES ("Thanh N", 1996, 2022, F-C, 5-7, 143, "Oct 1, 1996", "Alameda College")
        table = @input[2]# parse values
        values = @cli_input.split("VALUES").last # split @input string into array, get everything right of VALUES
        values.tr!("();", "").slice!(0)# clean up string

        # select everything in double quotes, reject indices with just quotes, empty strings, or just spaces
        arr = values.split(/(".*?"|[^",\s]+)(?=\s*,|\s*$)/).reject{|elem| elem == ', ' || elem == " " || elem == "" || elem.empty?}
        # validate query
        if (@input[1] != "INTO" || !table || @input[3] != "VALUES" || values.size == 0)
            puts "Invalid Syntax:\n\tSYNTAX: INSERT INTO `table` VALUES (column1, column2, column3, ...)"
            get_input()
        end
        
        @@csvr.insert(table) # initialize headers by using the .insert function, they can be accessed with @@csvr.headers
        newhash = {}
        # the following loop will take all the inputs and map them to a hash with the correct keys
        # The headers are extracted from @@csvr.headers
        # The output -> newhash = {:header1 => value1, :header2 => value2, ...}

        (0...arr.size).each do |i| # input: array , empty hash
            arr[i].gsub!('"',"") # removes the extra pair of quotes from a string
            if Integer(arr[i], exception:false).nil? # can the element NOT be cast as an integer?
                newhash[@@csvr.headers[i]] = arr[i] # if so, just add it to the hash as normal
                next
            end
            newhash[@@csvr.headers[i]] = arr[i].to_i # cast it as an integer, add it to a hash
        end

        
        @@csvr.values(newhash).run
        get_input()
    end

    # user for converting key values to it appropriate data type
    def match_symbol_to_data(arr)
        hash = {}
        arr.each_with_index do |element, index|
            if index.even?
                element.tr!(",= ","")
                if Integer(arr[index+1], exception: false).nil? 
                    hash[arr[index].to_sym] = arr[index+1].gsub('"',"")
                else
                    hash[arr[index].to_sym] = arr[index+1].gsub('"',"").to_i
                end
            end
        end
        return hash
    end

    def cli_update()
        # UPDATE data.csv SET college = "University of California, Santa Cruz", name = "Connor" WHERE name = 'Alex Abrines';
        # after cli_where => UPDATE data.csv SET college = "University of California, Santa Cruz", name = "Connor"
        table = @input[1]

        # validate query
        if (!table || @input[2] != "SET")
            puts "Invalid Syntax \n\tSYNTAX: FROM table SET column = value WHERE column2 = value2"
            get_input()
        end
    
        # get set values
        set_values = @cli_input.split(" SET ").last# get everything between WHERE and SET
        
        # split up set_values string but ignore comma inside double quote
        arr = set_values.split(/(".*?"|[^",\s]+)(?=\s*,|\s*$)/).reject{|elem| elem == ', ' || elem == " " || elem == "" || elem.empty?}

        # convert columns new content to hash
        hash = match_symbol_to_data(arr)
        
        # Thanh N,1996,2022,F-C,5-7,143,"Oct 1, 1996",Alameda College
        @@csvr.update(table).set(hash).run
        get_input
    end
    
    def cli_delete()
        table = @input[2]
        # validate query
        if (@input[1] != "FROM" || !table)
            puts "Invalid syntax"
            get_input()
        end
        @@csvr.delete.from(table).run
        get_input()
    end

    def cli_join()
    # SELECT name, weight FROM data.csv JOIN data_to_join ON name = player

    @cli_input, join_query = @cli_input.split(" JOIN ")
    table_to_join, data_to_join = join_query.split(" ON ")
    table_to_join.tr!(" ","")
    data_to_join = data_to_join.split(" = ")

    #puts "@@csvr.join(#{data_to_join[0]},#{table_to_join},#{data_to_join[1]})"
    @@csvr.join(data_to_join[0],table_to_join,data_to_join[1])
    end

    def cli_order()
        #SELECT column1, column2 FROM table_name ORDER BY column1 ASC|DESC; 
        #SELECT name, weight FROM data.csv ORDER BY name ASC
        @cli_input, parsed = @cli_input.split(" ORDER BY ")

        column, order = parsed.split(" ")
        @@csvr.order(column,order)
    end
end

interface = CLI_Interface.new

interface.get_input

