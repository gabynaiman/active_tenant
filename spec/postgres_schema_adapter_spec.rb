require 'spec_helper'

describe PostgresSchemaAdapter do

  let(:schema_adapter) { PostgresSchemaAdapter.new }

  it 'List all schemas' do
    schema_adapter.all
  end

  it 'Create schema' do
    schema_adapter.create
  end

end