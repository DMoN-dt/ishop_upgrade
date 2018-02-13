module SpamBotsRoutes
  def self.extended(router)
    router.instance_exec do
		
		## SPAM-VIRUS ROBOTS
		match 'admin' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'admin:smth' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'admin:smth/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'wp-login.php' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'webdav' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'myadmin/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'MyAdmin/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'mysqladmin/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'mysql/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'websql/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'dbadmin/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'db/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'phpmyadmin/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'phpmyadmin:smth/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'phpMyAdmin/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'phpMyAdmin:smth/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'php-my-admin/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'pma/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'scripts/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'bitrix/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'typo3/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'fck/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'xampp/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'muieblackcat' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'web/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'HNAP1' => 'welcome#error_RobotTryLogin', via: [:get, :post] # Routers Home Network Administration Protocol
		match 'modules/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'wp-content:smth' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'cgi-bin/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'moadmin/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'catalog/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match 'shop/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match '/CFIDE/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post] # ColdFusion
		match '/site/wp-includes/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match '/wp/wp-includes/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match '/blog/wp-includes/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match '/wp-includes/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match '/index.php/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match '/wordpress/wp-admin/*other' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		match '/LICENSE.php' => 'welcome#error_RobotTryLogin', via: [:get, :post]
		
    end
  end
end

		