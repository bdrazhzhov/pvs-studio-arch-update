require "ecr"
require "myhtml"
require "http/client"

CHECK_URL        = "https://pvs-studio.ru/ru/pvs-studio/download/"
FILENAME_PATTERN = /pvs-studio-(\d+\.\d+\.\d+\.\d+)-x86_64\.tgz/
OUTPUT_DIR       = "/tmp/output"
VERSION_FILENAME = "#{OUTPUT_DIR}/version"

def fetch_html(url)
  HTTP::Client.get(url) do |response|
    if response.status.success?
      return response.body_io.gets_to_end
    else
      puts "Ошибка: #{response.status}"
    end
  end
rescue ex
  puts "Ошибка запроса: #{ex.message}"
end

def find_table(html)
  parser = Myhtml::Parser.new(html)
  parser.css("table.table-hash").first?
end

def search_hash_and_version(table)
  table.css("tr").each do |row|
    tds = row.css("td")
    tds.each do |cell|
      match_result = FILENAME_PATTERN.match(cell.inner_text)
      next unless match_result

      return {version: match_result[1], hash: tds.first.css("p").first.inner_text.chomp}
    end
  end

  nil
end

def create_new_build(result)
  puts "Create new build"
  unless File.directory?(OUTPUT_DIR)
    Dir.mkdir(OUTPUT_DIR)
  end
  File.write(VERSION_FILENAME, result[:version])
  pkgbuild = ECR.render("#{__DIR__}/PKGBUILD.ecr")
  File.write("#{OUTPUT_DIR}/PKGBUILD", pkgbuild)
end

def process_table(table)
  result = search_hash_and_version(table)

  if result.nil?
    puts "Отсутсвуют данные о версии. Продолжение невозможно"
    return
  end

  if File.exists?(VERSION_FILENAME)
    version = File.read(VERSION_FILENAME)

    create_new_build(result) unless version == result[:version]
  else
    create_new_build(result)
  end
end

html = fetch_html(CHECK_URL)

if html
  table = find_table(html)
  if table
    process_table(table)
  else
    puts "Таблица с классом 'table-hash' не найдена."
  end
else
  puts "Не удалось загрузить страницу."
end
