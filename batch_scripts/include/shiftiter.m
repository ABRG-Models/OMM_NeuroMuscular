function new_iter = shiftiter (current_iter, iter_shift, range_size)
    new_iter = current_iter + iter_shift;
    if new_iter < 1
        new_iter = 1;
    elseif new_iter > range_size
        new_iter = range_size;
    end
end
