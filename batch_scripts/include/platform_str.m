function p_str = platform_str ()
    p_str = 'iceberg';
    d = exist('/usr/local/abrg');
    if d == 7
        p_str = 'ace2';
    end
end
