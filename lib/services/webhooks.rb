class AhaServices::Webhooks < AhaService
  string :hook_url
  
  def receive_create_feature
    http_post data.hook_url, payload.to_json
  end
  
  def receive_update_feature
    http_post data.hook_url, payload.to_json
  end

  def receive_create_release
    http_post data.hook_url, payload.to_json
  end
  
  def receive_update_release
    http_post data.hook_url, payload.to_json
  end
  
end
