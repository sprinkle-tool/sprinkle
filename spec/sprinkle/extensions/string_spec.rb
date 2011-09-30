require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe String, 'task name conversions' do
  
  it 'should be able to deliver a task name' do
    'build_essential'.to_task_name.should == 'build_essential'
  end
  
  it 'should convert all - chars to _ in the task name' do
    'build-essential'.to_task_name.should == 'build_essential'
  end
  
  it 'should convert multiple - chars to _ chars in the task name' do
    'build--essential'.to_task_name.should == 'build__essential'
  end
  
  it 'should lowercase the task name' do
    'BUILD-ESSENTIAL'.to_task_name.should == 'build_essential'
  end
  
end