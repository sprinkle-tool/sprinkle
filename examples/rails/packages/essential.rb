## Special package, anything that defines a 'source' package means build-essential should be installed for Ubuntu

package :build_essential do
  description 'Build tools'
  apt 'build-essential'
end
