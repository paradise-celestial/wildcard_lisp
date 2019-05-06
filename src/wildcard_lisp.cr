require "./token/tree"

# TODO: Write documentation for `WildcardLisp`
module WildcardLISP
  VERSION = "0.1.0"

  def self.exec(str : String)
    tree = TokenTree.from_string str
    tree.exec
  end

  # def self.exec(tree : TokenTree)
  #   card = tree.first.to_card
  #   args = tree[1..-1]
  #
  #   card.exec args
  # end
end
