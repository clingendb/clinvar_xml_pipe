# cut from an element of clinvar xml
#
# @Author Xin Feng
# @Date 05/12/2015
#
#
#
require 'progressPrinter'
require 'logging'

class ClinVarXMLTokenizedCutter
  def initialize(file, id)
    @file = File.open(file,'rb')
    @log = Logging.logger(STDERR)
    @log.level = :debug
    @clinvar_set_locs = []
    @start_line_no =  []
    @end_line_no =  []
    @total_lines_cnt = 0
    @clinvar_set_ids = []
    @KEY1 = '<ClinVarSet'
    @KEY2 = '/ClinVarSet'
    @id = id
    @lines_buffer = ''
  end

  def get_clinvar_set_locs_and_ids
    @file.each_line do |line|
      @total_lines_cnt += 1
      if line.include? @KEY1
        @start_line_no << @file.lineno
        @clinvar_set_ids << line.match(/<ClinVarSet ID=(.*)>/)[0]
      elsif line.include? @KEY2
        @end_line_no << @file.lineno
      end
    end
    if @start_line_no.length != @end_line_no.length
      raise "Incomplete clinvarset detected."
    end
    @file.rewind
  end

  def parse str
    puts @lines_buffer
  end

  def find_ind 
    @clinvar_set_ids.each_with_index do |id,ind|
      if id.include? @id
        return ind
      end
    end
    return nil
  end

  def run
    @log.info "Finding locations of each set"
    get_clinvar_set_locs_and_ids
    @log.info "..Done"
    @log.info "Total lines in the xml file:#{@total_lines_cnt}"
    @log.info "Total records in the xml file:#{@start_line_no.length}"
    dp = ProgressPrinter.new(@start_line_no.length)

    ind = find_ind 
    raise "Didnt find your id" if ind.nil?
    line_loc_ind = 0
    line_cnt = 1
    start_l_loc =  @start_line_no[ind]
    end_l_loc =  @end_line_no[ind]

    @file.each_line do |line|
      if line_cnt >= start_l_loc 
       puts line
      end
      line_cnt += 1
    end

  end
end