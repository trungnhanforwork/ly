Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.paths << Rails.root.join('app/javascripts')
Rails.application.config.assets.paths << Rails.root.join('app/assets/builds')
Rails.application.config.assets.precompile += %w[active_admin.css]
