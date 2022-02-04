require 'rexml/document'
require 'nokogiri'
require "pathname"

class Item
  @tag
  @id
  @attribute

  def initialize (tag, id, attribute)
    @tag = tag
    @id = id
    @attribute = attribute
  end

  def tag
    @tag
  end

  def id
    @id
  end

  def attribute
    @attribute
  end
end

@path = '/home/artyom-lisaev/atlantis/atlantis/atlantis-common/res/items/release'
@xmls = []

@wrong_items = []

# "Находим пути всех xml файлов от корневой папки"
def find_all_xml_path(path, file= false)
  path.children.collect do |child|
    if file and child.file?
      path = child.cleanpath.to_s
      @xmls << path
    elsif child.directory?
      find_all_xml_path(child, file) + [child]
    end
  end.select { |x| x }.flatten(1)
end

find_all_xml_path(Pathname.new(@path), true)

# "Загружаем из файла информацию о том, какие айтемы с какой айдишкой ищем и какой атрибут у них удаляем"
def load_what_searching
  File.read("/home/artyom-lisaev/needRemove").each_line { |line|
    splited_line = line.split(", ")
    tag = splited_line[0].chomp
    id = splited_line[1].chomp
    attribute = splited_line[2].chomp

    # @wrong_items[key] = splited_value

    @wrong_items << Item.new(tag, id, attribute)
}
end

load_what_searching

# "Читаем все найденные в find_all_xml_path xml. Находим нужный айтем и удаляем невалидный атрибут"
def fix_xml

  @xmls.each { |xml_file|
    sample_data = File.open(xml_file)
    parsed_info = Nokogiri::XML(sample_data)

    @wrong_items.each { |item|
        done = parsed_info.xpath("//#{item.tag}[@id='#{item.id}']").remove_attribute("#{item.attribute}").to_s
      if done.size != 0
        File.write(xml_file, parsed_info.to_xml)
      end
    }
}
end

fix_xml