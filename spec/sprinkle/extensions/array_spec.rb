require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Array, 'task name conversions' do
  
  it 'should be able to deliver a task name' do
    ['build_essential'].to_task_name.should == 'build_essential'
  end
  
  it 'should join multiple elements together with a _ char' do
    ['gdb', 'gcc', 'g++'].to_task_name.should == 'gdb_gcc_g++'
  end
  
  it 'should use the task name of the underlying array element' do
    string = 'build-essential'
    string.should_receive(:to_task_name).and_return('build_essential')
    [string].to_task_name.should == 'build_essential'
  end
    
end
