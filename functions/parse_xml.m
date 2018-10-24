function node = parse_xml(xml)
  %PARSE_XML parses an xml string into matlab data structures
  %
  %   PARSE_XML(STR) generates a tree of structs that contains the XML
  %   data structure. Each struct represents one node in the XML tree,
  %   which has the fields `children` and `attributes`. `attributes`
  %   are saved as structs. `children` are saved as a cell arrays of
  %   node structs and strings. Text nodes and CDATA nodes are
  %   automatically translated to strings. Comment nodes are ignored.

  % Copyright 2014 Bastian Bechtold
  % This code is public domain. Do what you want with it.

  node = struct();
  node.name = char(xml.getNodeName());
  node.children = get_children(xml);
  node.attributes = get_attributes(xml);
end

function children = get_children(xml)
  children = {};
  if ~xml.getLength()
    return
  end
  for idx=0:xml.getLength()-1
    name = char(xml.item(idx).getNodeName());
    if name(1) == '#'
      if strcmp(name, '#text')
        data = char(xml.item(idx).getData());
        data = regexprep(data, '\s', '');
        if length(data) ~= 0
          children = [children data];
        end
      elseif strcmp(name, '#comment')
      % ignore comments
      elseif strcmp(name, '#cdata-section')
        children = [children char(xml.item(idx).getData())];
      else
        children = [children char(xml.item(idx).toString())];
      end
    else
      children = [children parse_xml(xml.item(idx))];
    end
  end
end

function attr = get_attributes(xml)
  attr = struct();
  if ~xml.hasAttributes()
    return
  end
  xml_attr = xml.getAttributes();
  for idx=0:xml_attr.getLength()-1
    name = char(xml_attr.item(idx).getName());
    name = strrep(name, ':', '_');
    value = char(xml_attr.item(idx).getValue());
    attr.(name) = value;
  end
end
