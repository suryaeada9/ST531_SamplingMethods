
#!/usr/bin/env bash

USERNAME="suryaeada9"
REPO="$(basename "$PWD")"
OUTPUT="index.html"

{
cat <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Course Schedule</title>
<style>
body {
  font-family: Arial, sans-serif;
  max-width: 850px;
  margin: 40px auto;
  padding: 0 20px;
  color: #334155;
}
table { width: 100%; border-collapse: collapse; }
th, td {
  padding: 12px 16px;
  text-align: left;
  border-bottom: 1px solid #e2e8f0;
}
th { background: #f1f5f9; }
a { color: #2563eb; text-decoration: none; }
a:hover { text-decoration: underline; }
</style>
</head>
<body>
<h1>Course Schedule</h1>
<table>
<thead><tr><th>Week</th><th>Materials</th></tr></thead>
<tbody>
EOF

for dir in w[0-9]*_*/; do
    [ -d "$dir" ] || continue
    [ -f "${dir}index.html" ] || continue

    folder="${dir%/}"
    week="${folder#w}"
    week="${week%%_*}"

    [[ "$week" =~ ^[0-9]+$ ]] || continue

    printf '%s\t<tr><td>Week %s</td><td><a href="https://%s.github.io/%s/%s/#">%s</a></td></tr>\n' \
        "$week" "$week" "$USERNAME" "$REPO" "$folder" "$folder"
done | sort -n -k1,1 | cut -f2-

cat <<EOF
</tbody>
</table>
</body>
</html>
EOF
} > "$OUTPUT"

echo "Generated $OUTPUT"

