function append_pdfs(varargin)

    output = varargin{1};
    varargin = varargin(2:end);
    
    % Create the command file
    cmdfile = [tempname '.txt'];
    fh = fopen(cmdfile, 'w');
    fprintf(fh, '-q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="%s" -f', output);
    fprintf(fh, ' "%s"', varargin{:});
    fclose(fh);
    
    % Call ghostscript
    ghostscript(['@"' cmdfile '"']);
    
    % Delete the command file
    delete(cmdfile);

end