module LocalesRoutes
  def self.extended(router)
    router.instance_exec do
		
		### ===[ DEFAULT RUSSIAN Locale ]=== ###
		#['��������-������', '��������-������', 'Web-����������'].each do |scname|
		#	scope scname do
		#		get ''  => 'pricing#index'
		#		get '��������-��������-��������'  => 'pricing#e_commerce'
		#	end
		#end
		#
		### ===[ INTERNATIONAL Locales ]=== ###
		#avail_locales = /ru|en/ # /#{I18n.available_locales.join("|")}/
		#scope "(:locale)", locale: avail_locales do # , defaults: {locale: "en"}
		#	get '/contacts' => 'welcome#contacts'
		#
		#	scope "pricing" do
		#		get ''  => 'pricing#index', as: 'pricing'
		#		get 'e-commerce'       => 'pricing#e_commerce'
		#	end
		#
		#	root to: root_path
		#end
		#get '/:locale', locale: avail_locales, to: root_path
		
    end
  end
end

		

