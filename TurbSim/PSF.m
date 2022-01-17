function [ProductOfSmallPrimes]=PSF(Npsf, NumPrimes, subtract )

% !> This routine factors the number N into its primes. If any of those
% !! prime factors is greater than the NumPrimes'th prime, a value of 1
% !! is added to N and the new number is factored.  This process is 
% !! repeated until no prime factors are greater than the NumPrimes'th 
% !! prime.
% !!
% !! If subract is .true., we will subtract 1 from the value of N instead
% !! of adding it.
% 
%     !Passed variables
%     INTEGER,         INTENT(IN) :: Npsf                   !< Initial number we're trying to factor.
%     INTEGER,         INTENT(IN) :: NumPrimes              !< Number of unique primes.
%     INTEGER                     :: ProductOfSmallPrimes   !< The smallest number at least as large as Npsf, that is the product of small factors when we return.
%                                                           !! IF subtract is present and .TRUE., PSF is the largest number not greater than Npsf that is a  product of small factors.
%     LOGICAL,OPTIONAL,INTENT(IN) :: subtract               !< if PRESENT and .TRUE., we will subtract instead of add 1 to the number when looking for the value of PSF to return.
%
%     !Other variables
%     INTEGER                     :: incr                   ! +1 or -1 
%     INTEGER                     :: IPR                    ! A counter for the NPrime array
%     INTEGER                     :: NP                     ! A temp variable to determine if NPr divides NTR
%     INTEGER                     :: NPr                    ! A small prime number
%     INTEGER                     :: NT                     ! A temp variable to determine if NPr divides NTR: INT( NTR / NPr )
%     INTEGER                     :: NTR                    ! The number we're trying to factor in each iteration

    NPrime = [ 2, 3, 5, 7, 11, 13, 17, 19, 23 ];
    NFact = length(NPrime);
    
    DividesN1 = false(1,NFact);                             % We need to check all of the primes the first time through
    
    incr = 1;
    if ( nargin > 2 ) 
       if (subtract) 
          incr = -1;
       end
    end
    
    ProductOfSmallPrimes = round(abs(Npsf));

    while ( ProductOfSmallPrimes > 1 )
           % First:  Factor NTR into its primes.

       NTR = ProductOfSmallPrimes;

       for IPR=1:min( NumPrimes, NFact ) 

           if ( DividesN1(IPR) ) 
                   % If P divides N-1, then P cannot divide N.
               DividesN1(IPR) = false;               % This prime number does not divide ProductOfSmallPrimes; We'll check it next time.
           else

               while( mod(NTR,NPrime(IPR))==0 )
                   NTR = round(NTR / NPrime(IPR));
                   DividesN1(IPR) = true;            % This prime number divides ProductOfSmallPrimes, so we won't check it next time (on NProductOfSmallPrimes+1).
                   if ( NTR == 1 )
%                        disp(DividesN1(1:IPR))
                        fprintf('Original number: %8.0f\n', Npsf)
                        fprintf('   Final number: %8.0f\n', ProductOfSmallPrimes)
                        fprintf('     Difference: %8.0f\n', ProductOfSmallPrimes-Npsf)
                       return;                       % We've found all the prime factors, so we're finished
                   end
               end
                

            end %  DividesN1

       end % IPR
%        disp(NTR)
%        disp(DividesN1)

           % Second:  There is at least one prime larger than NPrime(NumPrimes).  Add or subtract
           %          a point to NTR and factor again.

       ProductOfSmallPrimes = ProductOfSmallPrimes + incr;

    end


return;

