class AddRussifyToGenMeasureUnits < ActiveRecord::Migration[5.1]
  def change
	add_column :gen_measurement_units, :rus_okei_code,			    :integer # Код единицы измерения по ОКЕИ
	add_column :gen_measurement_units, :rus_full_name,			    :string, limit: 30  # 
	add_column :gen_measurement_units, :rus_short_name,			    :string, limit: 12  # 
	add_column :gen_measurement_units, :top_sort_order,			    :integer, limit: 2  # 
	add_column :gen_measurement_units, :frequently_used_quantity,	:boolean, default: false # Часто используется в качестве измерения количества
	add_column :gen_measurement_units, :integer_only,				:boolean, default: false # Только целые числа
  end
end
