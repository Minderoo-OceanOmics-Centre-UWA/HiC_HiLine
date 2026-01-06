OGnum="OG-list.txt"

downloaddir=$1
 
# Generate the include filter arguments
include_filters=$(awk '{print "--include " $0 "*.p_ctg.fasta"}' "$OGnum" | xargs)
 
# Set your S3 bucket path
s3_bucket="pawsey0964:oceanomics-refassemblies"
 
# Run rclone with the include filters
rclone ls $s3_bucket $include_filters > to_download.txt
 
#second, make a loop that inserts the path into rclone to copy them onto your scratch using the file
for line in $(awk '{print $2}' to_download.txt); do
rclone copy $s3_bucket/${line}  $downloaddir
done
