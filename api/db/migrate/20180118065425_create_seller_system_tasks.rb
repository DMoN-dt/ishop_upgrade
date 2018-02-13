class CreateSellerSystemTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :seller_system_tasks do |t|
      t.timestamps
	  t.integer    "seller_id"
	  t.string     "name",                     limit: 70,   null: true # Наименование задачи
	  t.timestamp  "enabled_at"                                        # Время активации задачи
	  t.boolean    "state"                                             # Текущее состояние: true = Надо выполнить (активно), false = Выполнена (не активно)
	  t.integer    "reason_count"                                      # Количество причин (кол-во добавленных товаров/групп и т.п.)
	  t.integer    "reason_list", array: true, limit: 8                # Массив причин (id накладных и т.п.)
	  t.jsonb      "reason_params", array: true                        # Массив параметров причин (изменяемые значение с/на и т.п.)
    end
  end
end
