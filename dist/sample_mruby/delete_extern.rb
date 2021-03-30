# directoryの中の.hファイルを抽出
# 2行目に「use `mrbc」があったらmrbcで抽出したファイルとみなす
# ファイルの中身を読み込み、extern があったらその行を削除

def delete_extern 
  Dir.glob("./*.h") do |path|
    file = File.read(path)
    target = /use `mrbc/
    next if file !~ target
    p path
    file.sub!(/^extern const uint8_t .*$/, "")
    File.write(path, file)
  end
end