require 'csv'
module Csv
  
  class Writer
    def initialize(output)
      @output = output
    end
    def << csv_cells
      @output.write FasterCSV.generate_line(csv_cells, :force_quotes => true, :col_sep => ';')
    end
  end
  
  class Export
    def run(list_of_models_to_export)
      CSV.generate(:col_sep => ';', :force_quotes => true) do |output| 
        export(output,list_of_models_to_export)
      end
    end
    
    protected
    def export(output, list_of_models_to_export)
    end
  end
  
  class Column
    attr_reader :header
    def initialize(header, &cell_block)
      @header = header
      @cell_block = cell_block if block_given?
    end
    
    def cell(model)
      @cell_block.call(model)
    end
    
    def ==(other)
      other.is_a?(self.class) && header == other.header
    end
  end
  
  class ColumnSet
    def initialize(*columns)
      @columns = columns
    end 
    
    def header 
      @columns.collect {|col| col.header} 
    end
    
    def row(model)
      return empty_row unless model
      @columns.collect {|col| col.cell(model)}
    end
  
    def empty_row
      [''] * @columns.length
    end

    def <<(column)
      @columns << column
    end
    
    def ==(other)
      other.is_a?(self.class) && columns == other.columns
    end
    
    def to_s
      "ColumnSet(#{columns.collect{|c| c.header}.join(', ')})"
    end
    
    alias_method :inspect, :to_s
    
    protected 
    attr_reader :columns
  end
  
end

