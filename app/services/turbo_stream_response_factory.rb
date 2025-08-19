class TurboStreamResponseFactory
  def self.success_create(resource, message: nil)
    resource_name = resource.class.name.underscore
    message ||= "#{resource.class.model_name.human} criado com sucesso"
    
    [
      turbo_stream.append("#{resource_name.pluralize}_list", 
        partial: "#{resource_name.pluralize}/#{resource_name}_card", 
        locals: { resource_name.to_sym => resource }),
      turbo_stream.update("flash_messages", 
        partial: "layouts/flash", 
        locals: { flash: { success: message } }),
      turbo_stream.remove("new_#{resource_name}_modal")
    ]
  end

  def self.success_update(resource, message: nil)
    resource_name = resource.class.name.underscore
    message ||= "#{resource.class.model_name.human} atualizado com sucesso"
    
    [
      turbo_stream.update("#{resource_name}_#{resource.id}", 
        partial: "#{resource_name.pluralize}/#{resource_name}_card", 
        locals: { resource_name.to_sym => resource }),
      turbo_stream.update("flash_messages", 
        partial: "layouts/flash", 
        locals: { flash: { success: message } }),
      turbo_stream.remove("edit_#{resource_name}_modal")
    ]
  end

  def self.success_destroy(resource, additional_updates: [], message: nil)
    resource_name = resource.class.name.underscore
    message ||= "#{resource.class.model_name.human} deletado com sucesso"
    
    base_streams = [
      turbo_stream.remove("#{resource_name}_#{resource.id}"),
      turbo_stream.update("flash_messages", 
        partial: "layouts/flash", 
        locals: { flash: { success: message } })
    ]
    
    base_streams + additional_updates
  end

  def self.error(form_id, resource, partial_path)
    turbo_stream.update(form_id, 
      partial: partial_path, 
      locals: { resource.class.name.underscore.to_sym => resource })
  end

  private

  def self.turbo_stream
    Turbo::StreamsChannel
  end
end