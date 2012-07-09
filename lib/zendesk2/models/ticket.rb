class Zendesk2::Client::Ticket < Cistern::Model
  include Zendesk2::Errors
  identity :id,                type: :id
  attribute :external_id
  attribute :via
  attribute :created_at,       type: :time
  attribute :updated_at,       type: :time
  attribute :type
  attribute :subject
  attribute :description
  attribute :priority
  attribute :status
  attribute :recipient
  attribute :requester_id,     type: :integer
  attribute :submitter_id,     type: :integer
  attribute :assignee_id,      type: :integer
  attribute :organization_id,  type: :integer
  attribute :group_id,         type: :integer
  attribute :collaborator_ids, type: :array
  attribute :forum_topic_id,   type: :integer
  attribute :problem_id,       type: :integer
  attribute :has_incidents,    type: :boolean
  attribute :due_at,           type: :time
  attribute :tags,             type: :array
  attribute :fields,           type: :array

  def save
    if new_record?
      requires :subject, :description
      data = connection.create_ticket(params).body["ticket"]
      merge_attributes(data)
    else
      requires :identity
      data = connection.update_ticket(params.merge("id" => self.identity)).body["ticket"]
      merge_attributes(data)
    end
  end

  def destroy
    requires :identity

    connection.destroy_ticket("id" => self.identity)
  end

  def collaborators
    self.collaborator_ids.map{|cid| self.connection.users.get(cid)}
  end

  def collaborators=(collaborators)
    self.collaborator_ids= collaborators.map(&:identity)
  end

  def destroyed?
    !self.reload
  end

  def requester=(requester)
    self.requester_id= requester.id
  end

  def requester
    self.connection.users.get(self.requester_id)
  end

  def submitter
    self.connection.users.get(submitter_id)
  end

  private

  def params
    Cistern::Hash.slice(Zendesk2.stringify_keys(attributes), "external_id", "via", "requester_id", "submitter_id", "assignee_id", "organization_id", "subject", "description", "fields", "recipient", "status", "collaborator_ids")
  end

end
